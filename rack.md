# Introduction to Rack Applications

How does Rails work? As developers, we don't want to take our tools on faith. We want to know what's under the hood and how things work. This article and exercise explain one part of the vast picture of Rails (and Sinatra, too). Learning about **rack** is an important part of understanding how Ruby web technologies work.

According to the official README:

"Rack provides a minimal, modular and adaptable interface for developing web applications in Ruby. By wrapping HTTP requests and responses in the simplest way possible, it unifies and distills the API for web servers, web frameworks, and software in between (the so-called middleware) into a single method call." - The official Rack GitHub repo [can be found here.](https://github.com/rack/rack)

The key takeaway is that a rack application is just a Ruby object. This object sits between, e.g., Rails and a server. Without a web framework like Rails, we can also create a rack app directly. That's what we will do here.

## The Big Picture

Before we dive into the technical details, it would help to illuminate how the HTTP process and rack application work. That will inform how we build our first rack app. Let's break down the basic process:

1. We send an HTTP request.
2. The server parses the HTTP request and passes it our rack app.
3. Our rack app returns a response to the server.
4. The server sends a response back to the browser.

With that process as our road map, we can begin to build and understand our first rack app.

## Building a Rack Application

*A note about the web server: The web server and the rack application are two separate things. The web server is responsible for taking information back and forth from the browser. The web server parses the HTTP request and response into usable information. The rack application is responsible for taking in the parsed HTTP request and returning a response to the server.*

### Send HTTP Request

To begin this process, we have to choose the server we want to use. We are using WEBrick for this exercise because it’s a a simple HTTP web server library. You can read more about WEBrick in the Ruby docs.

Create a new ruby program called **app.rb**. The command to run a server, among other things, is part of the rack library. Require it.

```
require "rack"
```
Now, create the server and pass it the name of our app, which is currently set to ```nil```.
```
app = nil

Rack::Handler::WEBrick.run app
```
When we run the app, we should see something like the following:

```
➜  rack-work  ruby app.rb  
[2014-12-05 10:34:58] INFO  WEBrick 1.3.1  
[2014-12-05 10:34:58] INFO  ruby 2.0.0 (2014-02-24) [x86_64-darwin13.1.0]  
[2014-12-05 10:34:58] INFO  WEBrick::HTTPServer#start: pid=29912 port=8080
```

Using our browser, go to the default WEBrick port, which is identified above: ```localhost:8080```. That sends an HTTP request to our server.

### HTTP Request Parsed and Passed into Rack App


Since our local app variable is set to ```nil```, we must be expecting an error. It's going to be instructive. When we try to go to ```localhost:8080```, this error appears in the console.

```
[2014-12-05 10:35:05] ERROR NoMethodError: undefined method `call' for nil:NilClass
...
localhost - - [05/Dec/2014:10:35:05 EST] "GET / HTTP/1.1" 500 320
- -> /
```

The request made it to the server! But it appears we got a code 500 Internal Server Error response, because WEBrick tried to call #call on our app, which is not a method available to the Nil Class. Our app needs to be an object that has the #call method.

Let's try to fix that. You'll see that I'm going to be hacky. I'm just going to follow the error and see where it takes us. When we have finished this part of the exercise, we'll stop being hacky. Here is what's in **app.rb** now.

```
require 'rack'

class App
  def call
  end
end

app = App.new

Rack::Handler::WEBrick.run app

```
If we restart the server and try to go to the port, we now get this response.

```
[2014-12-05 11:30:16] ERROR ArgumentError: wrong number of arguments (1 for 0)
app.rb:6:in `call'
...
localhost - - [05/Dec/2014:11:30:16 EST] "GET / HTTP/1.1" 500 315
- -> /
```
So, the target has advanced. We have the right method, but the server tried to give it an argument, and we didn't define the method to take an argument.

What is happening is that our server is trying to call #call on our app, and it's also trying to pass the parsed HTTP request into the #call method, as an argument. The parsed HTTP request is a hash called the **environment**.

Let's provide for #call in our code, that takes an argument, and see what happens next. Since we know the server is going to pass the environment into #call, we should ```puts``` it. It would help to also call the #inspect method on the environment to see what the data structure looks like. Here is **app.rb**:

```
require 'rack'

class App
  def call(env)
    puts env.inspect
  end
end

app = App.new

Rack::Handler::WEBrick.run app
```
When restarting the server and going to ```localhost:8080```, we got a couple of golden nuggets. First, the console contains the output of the ```puts``` command:


```
{
  "GATEWAY_INTERFACE"=>"CGI/1.1",
  "PATH_INFO"=>"/",
  "QUERY_STRING"=>"",
  "REMOTE_ADDR"=>"::1",
  "REMOTE_HOST"=>"localhost",
  "REQUEST_METHOD"=>"GET",
  "REQUEST_URI"=>"http://localhost:8080/",
  "SCRIPT_NAME"=>"",
  "SERVER_NAME"=>"localhost",
  "SERVER_PORT"=>"8080",
  "SERVER_PROTOCOL"=>"HTTP/1.1",
  "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/2.0.0/2014-02-24)",
  "HTTP_HOST"=>"localhost:8080",
  "HTTP_CONNECTION"=>"keep-alive",
  "HTTP_CACHE_CONTROL"=>"max-age=0",
  "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.65 Safari/537.36",
  "HTTP_ACCEPT_ENCODING"=>"gzip, deflate, sdch",
  "HTTP_ACCEPT_LANGUAGE"=>"en-US,en;q=0.8",
  "rack.version"=>[1, 2],
  "rack.input"=>#<StringIO:0x007fa96b9ccdd8>,
  "rack.errors"=>#<IO:<STDERR>>,
  "rack.multithread"=>true,
  "rack.multiprocess"=>false,
  "rack.run_once"=>false,
  "rack.url_scheme"=>"http",
  "HTTP_VERSION"=>"HTTP/1.1",
  "REQUEST_PATH"=>"/"
}
```
The hash above is the environment, i.e., the parsed HTTP request that WEBrick is passing into the rack app. It has valuable information that we might be able to use. For example, ```"PATH_INFO"=>"/"``` and ```"REQUEST_METHOD"=>"GET"```.

But let's keep building this app. After the custom #call method performed ```puts``` on the environment, it proceeded to try to work with the app. We see an instructive error, which returns us to the path we're on.

###Response to the Server
```
[2014-12-05 11:56:13] ERROR NoMethodError: undefined method `each' for nil:NilClass
...
localhost - - [05/Dec/2014:11:56:13 EST] "GET / HTTP/1.1" 500 320
- -> /
```
While this error is not completely informative, we know what it's trying to do. The server is attempting to parse an HTTP response. It's specifically looking for an array containing HTML. Let's cure that error. We're still being hacky, but we can have #call return the data that the server expects (a properly structured HTTP response), by doing the following:

```
require 'rack'

class App
  def call(env)
    [200, {"Content-Type" => "text/html"}, ["Hello, world!"]]
  end
end

app = App.new

Rack::Handler::WEBrick.run app

```

Our last error complained that there was no array to call #each on. Now, ```["Hello, world!"]``` stands in the place that the #each method was previously called by the server. Let's see if this cures the errors.

We will re-run the server and hope for the best. What we want is the response code 200 that we put in our array and we also want the page to be properly rendered in our browser. Our server says:

```
localhost - - [05/Dec/2014:13:48:50 EST] "GET / HTTP/1.1" 200 2
- -> /
````
Excellent. The last stop on our original road map was the browser.

###Server Response to the Browser

The browser properly rendered the HTML:

```
Hello, world!
```
So, we have no errors to speak of, and the HTTP request and response worked. Success! We created the hacky version of our app.

## The Non-Hacky Version

Now, what would the app look like if it weren't as hacky? We have peeked at the errors and the data being moved around, for our learning benefit. But we should no longer use our custom App Class.

The Ruby Standard Library includes a Proc Class. A proc object already has the #call method, and it takes an argument in the way that the server wants to pass it in through #call.

Let's change **app.rb** to reflect this approach.

```
require 'rack'

app = Proc.new { [200, {"Content-Type" => "text/html"}, ["Hello, world!"]] }

Rack::Handler::WEBrick.run app
```

This will have the same apparent behavior as our previous configuration. And now, we better understand what magic is happening inside WEBrick. So, let's make a more useful app, which is the challenge of this lesson.

# Challenge

Right now, our server responds with ```Hello, world!``` in the browser. To anything. That means ```localhost:8080```, ```localhost:8080/foo``` and ```localhost:8080/bar``` all give us ```Hello, world!```.

Since our environment contains the value of ```PATH_INFO```, we know we have access to the path before we return an HTTP response array. However, we currently don't have any intelligent code distinguishing among the different values of ```PATH_INFO```.

We can do better than that. Let's try to build a rack app that gives us different routes, and responds with different strings accordingly.

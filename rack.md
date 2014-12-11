# Introduction to Rack Applications

How does Rails work? As developers, we don't want to take our tools on faith. We want to know what's under the hood and how things work. This article and exercises explain one part of the vast picture of Rails (and Sinatra, too). Learning about **rack** is an important part of understanding how Ruby web technologies work.

According to the official README:

"Rack provides a minimal, modular and adaptable interface for developing web applications in Ruby. By wrapping HTTP requests and responses in the simplest way possible, it unifies and distills the API for web servers, web frameworks, and software in between (the so-called middleware) into a single method call." - The official Rack GitHub repo [can be found here.](https://github.com/rack/rack)

It makes somewhat more sense from blogger Adam Hawkins:  

"Rack is the HTTP interface for Ruby. Rack defines a standard interface for interacting with HTTP and connecting web servers. Rack makes it easy to write HTTP facing applications in Ruby. Rack applications are shockingly simple. There is the code that accepts a request and code serves the response. Rack defines the interface between the two." - [Rack from the Beginning](http://hawkins.io/2012/07/rack_from_the_beginning/)

## The Road Map

Before we dive into the technical details, it would help to illuminate how the HTTP process and rack application work at a basic level. That will inform how we build our first rack app. Let's break down the basic process:

1. We send an HTTP request.
2. The server parses the HTTP request and passes it into our rack app.
3. Our rack app returns a response to the server.
4. The server sends a response back to the browser.

At heart, the road map illustrates the purpose of rack. With our browser and server running, the browser sends a request by pointing to a URL. The server then provides us some magic to clean up the request and turn it into something we can use. That's where rack finds it's place. Rack is the first stop for that parsed and ready HTTP request. Rack could then take the parsed request and hand it to Rails or Sinatra. For this assignment, our rack app will provide all of the behavior, in and of itself. So, we will handle the parsed request. Since a rack app is just Ruby code, that means we have an opportunity to use this easy to learn and expressive language to determine the response we'll send to the server. The server then sends (usually) a string of HTML back to the browser for rendering.

## Building a Rack Application

### Send HTTP Request

To begin this process, we have to choose the server we want to use. We are using WEBrick for this exercise because it’s a a simple HTTP web server library. You can read more about WEBrick in the Ruby docs.

Create a new ruby program called **app.rb**. The command to run a server, among other things, is part of the rack library. Require it.

```
require "rack"
```
Now, create the server and pass it the name of our app, which is currently assigned to ```nil```.
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

Using our browser, go to the default WEBrick port, which is identified above: ```localhost:8080```. That sends an HTTP request to our server, which is the first important event in our road map.

### HTTP Request Parsed and Passed into Rack App


Since our local app variable is set to ```nil```, we are expecting an error. It's going to be instructive. When we try to go to ```localhost:8080```, this error appears in the console.

```
[2014-12-05 10:35:05] ERROR NoMethodError: undefined method `call' for nil:NilClass
...
localhost - - [05/Dec/2014:10:35:05 EST] "GET / HTTP/1.1" 500 320
- -> /
```

The request made it to the server! But it appears we got a code 500, because WEBrick tried to call #call on our app, which is not a method available to the Nil Class. That causes an "Internal Server Error". But the error has showed us what the server is expecting. Our app needs to be an object that has the #call method.

Let's try to fix that in a hacky way. We're just going to follow the error and see where it takes us. At the end of this lesson, we'll stop being hacky. Here is what's in **app.rb** now.

```
require 'rack'

class App
  def call
  end
end

app = App.new

Rack::Handler::WEBrick.run app

```
Let's try the same actions and see if the error has changed in a helpful way. If we restart the server and try to go to the port, we now get this response.

```
[2014-12-05 11:30:16] ERROR ArgumentError: wrong number of arguments (1 for 0)
app.rb:6:in `call'
...
localhost - - [05/Dec/2014:11:30:16 EST] "GET / HTTP/1.1" 500 315
- -> /
```
Interesting. The server expected #call and that's what we gave it. Now, the target has advanced. We have the right method, but the server tried to give it an argument, and we didn't define the method to take an argument.

What is happening is that our server is trying to call #call on our app, and it's also trying to pass the parsed HTTP request into the #call method, as an argument. This is the next important event in our road map.
Having the parsed HTTP request available in our app will later allow us to program all kinds of exciting behavior in response to the HTTP request. So, in what way is the HTTP request prepared for our use? The parsed HTTP request is a hash called the **environment**. A hash is a Ruby data type that we should know how to navigate. See more about the Hash Class in the Ruby docs.

Now, let's provide for #call in our code, that takes an argument, and see what happens next. Since we know the server is going to pass the environment into #call, we should ```puts``` it. It would help to also call the #inspect method on the environment to see what the data structure looks like. Here is **app.rb**:

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
The hash above is the environment, i.e., the parsed HTTP request that WEBrick is passing into the rack app. It has valuable information that we might be able to use. For example, ```"PATH_INFO"=>"/"``` and ```"REQUEST_METHOD"=>"GET"```. This data is going to be the basis of our rack app's behavior.

Let's keep building. After the custom #call method performed ```puts``` on the environment, it proceeded to try to work with the app. We see another error and it's instructive, which returns us to the path we're on.

###Response to the Server

Not only should we take in the environment, but we have to return something.

```
[2014-12-05 11:56:13] ERROR NoMethodError: undefined method `each' for nil:NilClass
...
localhost - - [05/Dec/2014:11:56:13 EST] "GET / HTTP/1.1" 500 320
- -> /
```
While this error is not completely informative, we know what it's trying to do. The server is attempting to parse an HTTP response. It's specifically looking for an array containing HTML.

Let's cure that error. We're still being hacky, but we can have #call return the data that the server expects (a properly structured HTTP response; aka, a **triplet**), by doing the following:

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

Our last error complained that there was no array to call #each on. Now, ```["Hello, world!"]``` stands in the place that the #each method was previously called by the server. Let's see if this advances us to the next step. Notice: we take in the environment with the implementation above, but we aren't doing anything with it.

We will re-run the server and hope for the best when we go to ```localhost:8080```. What we want is the response code 200 that we put in our array and we also want the page to be properly rendered in our browser. Our server says:

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

The Ruby Standard Library includes a Proc Class. A proc object already has the #call method, and it takes an argument in the way that the server wants to pass it in through #call. And a proc object returns a block of code that we define. Perfect.

Let's change **app.rb** to reflect this approach.

```
require 'rack'

app = Proc.new do |env|
  [200, {"Content-Type" => "text/html"}, ["Hello, world!"]]
end

Rack::Handler::WEBrick.run app
```

This will have the same apparent behavior as our previous configuration, with a less unorthodox approach. You'll notice that Proc syntax and behavior align nicely with what WEBrick expects from our app. So, let's make a more useful app, which is the challenge of this lesson.

# BEERS: Implementing Routes - Challenge 1

Right now, our server responds with ```Hello, world!``` in the browser. To anything. That means ```localhost:8080```, ```localhost:8080/foo``` and ```localhost:8080/bar``` all give us ```Hello, world!```. The server is sending us the same content, every time.

Since our environment contains the value of ```PATH_INFO```, we know we have access to the path. Our rack app should provide different behavior, depending on the value of ```PATH_INFO```. Let's build a rack app that gives us different **routes**, which are paths that the interpreter can choose from in responding to the server. We should respond with different HTML strings according to the route accessed.

Specifically, we want "/beers" to return this string of HTML: ```<h1>BEERS</h1>```. Every other path should return ```<h1>404: Page does not exist.</h1>```.

###First Steps

Creating a rack app in the non-hacky way required us to use a proc object. That is because a proc object returns a block of code, and the Proc Class provides us with the method #call, into which we can pass the environment.

In our block, we have access to ```env```.

```
require 'rack'

app = Proc.new do |env|
  # We can call env in here.

  [200, {"Content-Type" => "text/html"}, ["Hello, world!"]]
end

Rack::Handler::WEBrick.run app
```
In addition, the Rack Class provides us with some special objects to make rack app development convenient.

```
require 'rack'

app = Proc.new do |env|
  request = Rack::Request.new(env)
  # Call on request.methods to see what is available.
  [200, {"Content-Type" => "text/html"}, ["Hello, world!"]]
end

Rack::Handler::WEBrick.run app
```
Using a language shell for Ruby like Pry or IRB. Call #methods on ```request```. See what is available to you.

Hint: You can build parts of the response triplet by calling methods on this object: ```Rack::Response.new(env)```. For example, try this assignment ```response.body = ["Hello, World"]```.  

Good luck.

# BEERS: Implementing Parameters - Challenge 2

Now that we know how to create different behavior depending on the path found in the environment, the next step is to use some of the information from the path to inform the string that we send to the server from our rack app. We need to take information dynamically from the URL, as a **parameter**, and move it through our rack app. Our goal is to display it on our page for our predetermined "/beers" routes.

Specifically, we want to point our browser to "/beers/pilsner" or "/beers/IPA" or "/beers/stout" and be able to see "PILSNER" or "IPA" or "STOUT" as our headlines, respectively. Every other path should return ```<h1>404: Page does not exist.</h1>```.  This requires us to dynamically take part of the string that comes after "/beers" and call it in our HTML body.  

Good luck.

# Parameters II: Implementing Rock, Paper, Scissors - Challenge 3

Let's shelve our BEERS app for now. For this challenge, using the parameters given to us in the URL, we want to implement a game of Rock, Paper, Scissors. The rules of this game can be found [here](#).

The user will decide what she wants to throw by going to one of the three paths: "/rock" or "/paper" or "/scissors". The rack app will use Ruby logic to randomly respond with a throw of its own, which will be enough information to determine the winner.

The output in the browser should look like this in raw HTML:

```
<h1>Rock, Paper, Scissors</h1>
  <ul>
    <li>The player throws: Paper</li>
    <li>The computer throws: Rock</li>
    <li>The player wins!</li>
  </ul>
```
This exercise will expand the amount of logic that we're using in our rack application.  

Good luck.

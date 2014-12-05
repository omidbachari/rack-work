require 'rack'

app = Proc.new do |env|
  if env['PATH_INFO'] == '/'
    [200, {"Content-Type" => "text/html"}, ["Home page"]]
  elsif env['PATH_INFO'] == '/beers'
    [200, {"Content-Type" => "text/html"}, ["I love beers!"]]
  else
    [200, {"Content-Type" => "text/html"}, ["GTFO"]]
  end
end

Rack::Handler::WEBrick.run app


#app = Proc.new { [200, {}, ["str"]] }

#
# call
# env
# each

#A rack application is an object. This object comes between Sinatra and the your server. I used the WEBrick server.

#When WEBrick receives a request from your browser, WEBrick parses it and then it interacts with your rack application by doing the following:

#Passing the parsed request into the object as the environment, calling


#A Rack application is an Ruby object that responds to the method #call. It takes exactly one argument, the environment and returns an Array of exactly three values: The status, the headers, and the body.

#Informally, a Rack application is a thing that responds to #call and takes a hash as argument, returning an array of status, headers and a body.

#The best way to describe a rack application is to understand what it does.

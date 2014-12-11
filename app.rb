require 'rack'
require 'pry'

app = Proc.new do |env|
  request = Rack::Request.new(env)
  response = Rack::Response.new(env)
  binding.pry
  [200, {"Content-Type" => "text/html"}, ["Home page"]]
end

Rack::Handler::WEBrick.run app

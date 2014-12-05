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

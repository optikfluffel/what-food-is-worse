require './server.rb'
use Rack::Deflater
run Sinatra::Application

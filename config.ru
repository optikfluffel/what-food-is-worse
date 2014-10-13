require './server.rb'
use Rack::Deflater
register Sinatra::AssetPack
run Sinatra::Application

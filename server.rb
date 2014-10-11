require 'sinatra'
require_relative 'models/user.rb'

get '/' do
	erb :index
end

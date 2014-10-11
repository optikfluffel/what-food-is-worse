require 'sinatra'
require 'bcrypt'
require_relative 'models/user.rb'
require_relative 'models/data.rb'

configure :development do
  MongoMapper.database = 'food'
end

# TODO: put somewhere less senseless
User.ensure_index(:username)
Product.ensure_index(:rnd)
use Rack::Session::Pool


helpers do
  def authenticated?
    !session[:username].nil?
  end

  def username
    session[:username]
  end
end


get '/' do
	erb :index
end


post '/register' do
  salt = BCrypt::Engine.generate_salt
  hash = BCrypt::Engine.hash_secret(params[:password], salt)

  user = User.new(:username => params[:username], :hash => hash, :salt => salt)

  user.save!

  session[:username] = user[:username]

  redirect '/'
end


post '/login' do
  user = User.first(:username => params[:username])

  unless user.nil?
    if user[:hash] == BCrypt::Engine.hash_secret(params[:password], user[:salt])
      session[:username] = params[:username]
    else
      redirect '/login'
    end
  end

  redirect '/'
end


get '/logout' do
  if authenticated?
    session.clear
    redirect '/'
  else
    halt 401, 'Not authorized.'
  end
end

require 'sinatra'
require 'json'
require 'bcrypt'
require_relative 'models/user.rb'
require_relative 'models/data.rb'

configure :development do
  MongoMapper.database = 'food'

  # TODO: put somewhere less senseless
  use Rack::Session::Pool, :key => 'oejlydfiiiliqewzioc4q8327498p32c', :expire_after => 60 * 30
end

configure :production do
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOSOUP_URL']}}, 'production')
  use Rack::Session::Pool, :key => ENV['SESSION_KEY']
end

configure do
  User.ensure_index(:username)
  Product.ensure_index(:rnd)
end

helpers do
  def protected!
    redirect '/' unless authenticated?
  end

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

get "/json/play/?" do
  protected!
  content_type :json

  game = Game.new.generate_new_game_with_random_products_and_mystery

  game.to_json
end

get '/play/?' do
  protected!

  game = Game.new.generate_new_game_with_random_products_and_mystery

  the_user = User.first(:username => session[:username])
  the_user.games << game

  if the_user.save!
    #TODO better error handling probably someday maybe
    p "okok en game würde gespeichert"
  else
    p "meeeeep"
  end

  erb :play, :locals => {:game => game}
end

post '/play/?' do
  protected!

  the_user = User.first(:username => session[:username])

  game_id = params['game']
  guess_id = params['guess']

  game = the_user.games.find(game_id)

  mystery = game.mystery

  product_one = game.products[0]
  product_two = game.products[1]

  candidate_one = product_one.nutritions.select{ |nutrition| nutrition.name == mystery }
  candidate_two = product_two.nutritions.select{ |nutrition| nutrition.name == mystery }

  maximum = [candidate_one[0].quantity, candidate_two[0].quantity].max

  proposed_solution = Product.find(guess_id).nutritions.select{ |nutrition| nutrition.name == mystery }

  if game.higher
    correct = maximum == proposed_solution[0].quantity
  else
    correct = maximum != proposed_solution[0].quantity
  end

  if correct
    game.win = correct
    game.save!
  end

  JSON :correct => correct
end


post '/register/?' do
  salt = BCrypt::Engine.generate_salt
  hash = BCrypt::Engine.hash_secret(params[:password], salt)

  user = User.new(:username => params[:username], :hash => hash, :salt => salt)

  user.save!

  session[:username] = user[:username]

  redirect '/'
end


post '/login/?' do
  user = User.first(:username => params[:username])

  unless user.nil?
    if user[:hash] == BCrypt::Engine.hash_secret(params[:password], user[:salt])
      session[:username] = params[:username]
    else
      # TODO: show flash error
      redirect '/'
    end
  else
    halt 401, 'Not authorized.'
  end

  redirect '/'
end


get '/logout/?' do
  if authenticated?
    session.clear

    # TODO: show flash message
    redirect '/'
  else
    halt 401, 'Not authorized.'
  end
end

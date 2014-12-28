require 'sinatra'
require 'json'
require 'bcrypt'
require_relative 'models/user.rb'
require_relative 'models/data.rb'

configure :development do
  use Rack::Session::Pool, :key => 'thisisoursuperduperprivatekey!!', :expire_after => 60 * 10
  MongoMapper.database = 'food'
end

configure :production do
  use Rack::Session::Pool, :key => 'session', :expire_after => 60 * 60
  MongoMapper.setup({'production' => {'uri' => ENV['MONGOSOUP_URL']}}, 'production')
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

  the_user = User.first(:username => session[:username])
  the_user.games << game

  if the_user.save!
    #TODO better error handling probably someday maybe
    p "okok en game würde gespeichert"
  else
    p "meeeeep"
  end

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

  game.win = correct
  game.save!

  JSON :correct => correct
end


get '/stats/?' do
  protected!

  the_user = User.first(:username => session[:username])

  games_lost_overall = the_user.games.where(:win => false).count
  games_won_overall = the_user.games.where(:win => true).count

  games_lost_last_week = the_user.games.where(:created_at.gte => Time.now.midnight - 7.days, :win => false).count
  games_won_last_week = the_user.games.where(:created_at.gte => Time.now.midnight - 7.days, :win => true).count

  games_lost_today = the_user.games.where(:created_at.gte => Time.now.midnight - 1.days, :win => false).count
  games_won_today = the_user.games.where(:created_at.gte => Time.now.midnight - 1.days, :win => true).count

  p "games_lost_last_week #{games_lost_last_week}"
  p "games_won_last_week #{games_won_last_week}"

  stats = {
    :lost_overall => games_lost_overall,
    :won_overall => games_won_overall,
    :lost_last_week => games_lost_last_week,
    :won_last_week => games_won_last_week,
    :lost_today => games_lost_today,
    :won_today => games_won_today
  }

  erb :stats, :locals => {:stats => stats}
end


post '/register/?' do
  salt = BCrypt::Engine.generate_salt
  hash = BCrypt::Engine.hash_secret(params[:password], salt)

  user = User.new(:username => params[:username], :hash => hash, :salt => salt)

  begin
    user.save!
  rescue MongoMapper::DocumentNotValid => e
    #TODO warn user
    redirect '/'
  end

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

get '/supersecret/?' do # jk ;D - you all can know if you want to
  "Users: #{User.all.count}\nGames lost: #{Game.where(:win => false).count}\nGames won: #{Game.where(:win => true).count}"
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

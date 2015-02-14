require 'rake'
require 'sinatra'
require 'json'
require 'bcrypt'
require 'sinatra/r18n'
require 'sinatra/content_for'
require_relative 'models/user.rb'
require_relative 'models/data.rb'

configure :development do
  use Rack::Session::Pool, :key => 'thisisoursuperduperprivatekey!!', :expire_after => 60 * 10
  MongoMapper.database = 'food'
end

configure :test do
  use Rack::Session::Pool, :key => 'session', :expire_after => 60
  MongoMapper.database = 'food-test'
end

configure :production do
  use Rack::Session::Pool, :key => 'session', :expire_after => 60 * 60 * 24 * 14

  MongoMapper.connection = Mongo::Connection.new(ENV["OPENSHIFT_MONGODB_DB_HOST"], ENV["OPENSHIFT_MONGODB_DB_PORT"].to_i)
  MongoMapper.database = ENV["OPENSHIFT_APP_NAME"]
  MongoMapper.database.authenticate(ENV["OPENSHIFT_MONGODB_DB_USERNAME"], ENV["OPENSHIFT_MONGODB_DB_PASSWORD"])

  set :static_cache_control, [:public, :max_age => 60 * 60 * 24 * 14]
end

configure do
  User.ensure_index(:username)
  Product.ensure_index(:rnd)

  #set default locale
  R18n::I18n.default = 'de'
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

before do
  session[:locale] ||= 'de'
  the_user = User.first(:username => session[:username])
  session[:locale] = the_user.locals unless the_user.nil?
end

error 401 do
  redirect '/401'
end

get '/' do
  erb :index
end

get '/401/?' do
  erb :"401"
end

get '/setlocals/:id/?' do |code|
  session[:locale] = code

  protected!

  the_user = User.first(:username => session[:username])
  the_user.locals = code

  if the_user.save!
    #TODO better error handling probably someday maybe
    p "okok en game würde gespeichert"
  else
    p "meeeeep"
  end

  redirect back
end


get '/play/?' do
  protected!

  the_user = User.first(:username => session[:username])

  # Check if the user has an unfinished game
  last_existing_game = the_user.games.sort(:created_at.desc).first
  if last_existing_game.nil?
    last_existing_game_has_unanswered_questions = false
  else
    unanswered_questions = last_existing_game.questions.keep_if { |question| question.answered_correct.nil? }
    last_existing_game_has_unanswered_questions = unanswered_questions.length > 0
  end

  unless last_existing_game_has_unanswered_questions
    game = Game.new.generate_new_game_with_random_questions
    the_user.games << game
    current_question = game.questions[0]
    current_progress = 0
  else
    game = last_existing_game
    current_question = unanswered_questions[0]
    current_progress = ((12 - unanswered_questions.length) * 100 / 12).round
  end

  if the_user.save!
    #TODO better error handling probably someday maybe
    p "okok en game würde gespeichert"
  else
    p "meeeeep"
  end

  erb :play, :locals => {:game => game, :current_question => current_question, :current_progress => current_progress}
end


get "/json/play/?" do
  protected!
  content_type :json

  the_user = User.first(:username => session[:username])

  # Check if the user has an unfinished game
  last_existing_game = the_user.games.sort(:created_at.desc).first
  if last_existing_game.nil?
    last_existing_game_has_unanswered_questions = false
  else
    unanswered_questions = last_existing_game.questions.keep_if { |question| question.answered_correct.nil? }
    last_existing_game_has_unanswered_questions = unanswered_questions.length > 0
  end

  unless last_existing_game_has_unanswered_questions
    game = Game.new.generate_new_game_with_random_questions
    the_user.games << game
    current_question = game.questions[0]
    current_progress = 0
  else
    game = last_existing_game
    current_question = unanswered_questions[0]
    current_progress = ((12 - unanswered_questions.length) * 100 / 12).round
  end

  if the_user.save!
    #TODO better error handling probably someday maybe
    p "okok en game würde gespeichert"
  else
    p "meeeeep"
  end

  JSON :current_question => current_question.to_json, :current_progress => current_progress, :current_points => game.points
end


post '/play/?' do
  protected!

  the_user = User.first(:username => session[:username])

  game_id = params['game']
  question_id = params['question']
  guess_id = params['guess']

  game = the_user.games.find(game_id)
  current_question = game.questions.find(question_id)

  mystery =     current_question.mystery
  product_one = current_question.products[0]
  product_two = current_question.products[1]

  candidate_one = product_one.nutritions.select{ |nutrition| nutrition.name == mystery }
  candidate_two = product_two.nutritions.select{ |nutrition| nutrition.name == mystery }

  maximum = [candidate_one[0].quantity, candidate_two[0].quantity].max

  proposed_solution = Product.find(guess_id).nutritions.select{ |nutrition| nutrition.name == mystery }

  if current_question.higher
    current_answer_is_correct = maximum == proposed_solution[0].quantity
  else
    current_answer_is_correct = maximum != proposed_solution[0].quantity
  end

  if current_answer_is_correct
    game.points += 100
  else
    game.points -= 200
  end

  current_question.answered_correct = current_answer_is_correct

  game.save!

  JSON :correct => current_answer_is_correct
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
      session[:locale] = user.locals
    else
      halt 401 # Not authorized
    end
  else
    halt 401 # Not authorized
  end

  redirect '/'
end


get '/logout/?' do
  if authenticated?
    session.clear

    # TODO: show flash message
    redirect '/'
  else
    halt 401 # Not authorized
  end
end


get '/stats/?' do
  protected!

  the_user = User.first(:username => session[:username])

  games_lost_overall = the_user.games.where(:points.lt => 0).count
  games_won_overall = the_user.games.where(:points.gte => 0).count

  games_lost_last_week = the_user.games.where(:created_at.gte => Time.now.midnight - 7.days, :points.lt => 0).count
  games_won_last_week = the_user.games.where(:created_at.gte => Time.now.midnight - 7.days, :points.gte => 0).count

  games_lost_today = the_user.games.where(:created_at.gte => Time.now.midnight - 1.days, :points.lt => 0).count
  games_won_today = the_user.games.where(:created_at.gte => Time.now.midnight - 1.days, :points.gte => 0).count

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


get '/leaderboard/?' do
  protected!
  the_user = User.first(:username => session[:username])
  the_users_points = the_user.games.reduce(0) { |sum, x| sum + x.points }

  # TODO: this isn't performant, make it so
  all_users_with_scores = User.all.map! do |user|
    total_points = user.games.reduce(0) { |sum, x| sum + x.points }
    { :username => user.username, :total_points => total_points }
  end

  all_users_with_scores.sort! { |a,b| b[:total_points] <=> a[:total_points] } # supports negative integers instead of using '-' sign for sort

  leaders = all_users_with_scores.first(10)

  erb :leaderboard, :locals => {:leaders => leaders}
end


get '/scripts.js' do
  content_type :js
  erb "scripts.js".to_sym, :layout => false
end


get '/supersecret/?' do # jk ;D - you all can know if you want to
  "Users: #{User.all.count}\nGames lost: #{Game.where(:win => false).count}\nGames won: #{Game.where(:win => true).count}"
end

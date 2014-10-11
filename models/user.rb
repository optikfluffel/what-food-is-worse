require 'mongo_mapper'

class User
	include MongoMapper::Document

	key :username, String, :required => true, :length => 3..50, :unique => true
	key :hash,     String, :required => true
	key :salt,     String, :required => true

	many :games

	timestamps!
end

class Game
	include MongoMapper::EmbeddedDocument

	attr_accessor :question

  def generate_new_game_with_random_products_and_mystery
    the_game = Game.new

    #TODO: check on the same Product
    the_game.products << Product.new.random
    the_game.products << Product.new.random

    first_game = the_game.products[0]

    begin
      random_nutrition = first_game.nutritions[rand(first_game.nutritions.length)]
    end while the_game.products[1].nutritions.include?(:name => random_nutrition.name)

		the_game.mystery = random_nutrition.name.sub('davon ', '').sub('Energiewert', 'Kilokalorien')

		basic_text = 'Welches der beiden Produkte hat '
		mehr_oder_weniger = ['mehr ', 'weniger '][rand(2)]

		the_game.question = basic_text + mehr_oder_weniger + the_game.mystery + '?'

    the_game
  end

	key :mystery, String, :required => true # aka nutrition name to guess
	key :win, Boolean, :required => true, :default => false

	key :product_ids, Array
  many :products, :in => :product_ids

	timestamps!
end

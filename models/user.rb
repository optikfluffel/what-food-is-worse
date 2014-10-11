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

	attr_accessor :question, :mystery_text

  def generate_new_game_with_random_products_and_mystery
    the_game = Game.new

    #TODO: check on the same Product
    the_game.products << Product.new.random
    the_game.products << Product.new.random

    #TODO: check on the same nutrition value
    array_one = the_game.products[0].nutritions.delete_if{ |n| n.quantity.nil? }.map { |nutritions| nutritions.name  }
    array_two = the_game.products[1].nutritions.delete_if{ |n| n.quantity.nil? }.map { |nutritions| nutritions.name  }
    array_union = array_one & array_two

    random_mystery = array_union[rand(array_union.length)]

		the_game.mystery = random_mystery
		the_game.mystery_text = random_mystery.sub('davon ', '').sub('Energiewert', 'Kilokalorien')

		the_game.higher = [true, false][rand(2)]

		if the_game.higher
			higherText = 'Mehr '
		else
			higherText = 'Weniger '
		end

		the_game.question = higherText + the_game.mystery_text + '?'

    the_game
  end

	key :mystery, String, :required => true # aka nutrition name to guess
	key :win, Boolean, :required => true, :default => false
	key :higher, Boolean, :required => true

	key :product_ids, Array
  many :products, :in => :product_ids

	timestamps!

  def to_json(*a)
      {
        :id => _id,
        :question => question,
        :products => products.map { |prod| prod.to_json }
      }.to_json(*a)
  end
end

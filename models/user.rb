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

	key :mystery, String, :required => true # aka nutrition name to guess
	key :win, Boolean, :required => true

	key :product_ids, Array
  many :products, :in => :product_ids

	timestamps!
end

require 'mongo_mapper'

class User
	include MongoMapper::Document

	key :username, String, :required => true, :length => 3..50, :unique => true
	key :hash,     String, :required => true
	key :salt,     String, :required => true

	timestamps!
end

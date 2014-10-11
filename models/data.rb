require 'mongo_mapper'

class Product
  include MongoMapper::Document

  key :productNummber, String, :require => true
  key :name, String, :require => true
  key :imgurl, String, :require => true
  many :nutritions

  timestamps!
end

class Nutrition
  include MongoMapper::EmbeddedDocument

  key :name, String, :require => true
  key :unit, String, :require => true
  key :quantity, Integer, :require => true
end

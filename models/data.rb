require 'mongo_mapper'
require 'securerandom'

class Product
  include MongoMapper::Document

  key :productNummber, String, :require => true
  key :name, String, :require => true
  key :imgurl, String, :require => true
  key :rnd, Float, :require => true

  timestamps!

  many :nutritions

  def random
    p = Product.first(:rnd.gte => rand())
    self.random if p == nil

    p
  end
end

class Nutrition
  include MongoMapper::EmbeddedDocument

  key :name, String, :require => true
  key :unit, String, :require => true
  key :quantity, Integer, :require => true
end

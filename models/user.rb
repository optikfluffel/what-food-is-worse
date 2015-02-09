require 'mongo_mapper'
include R18n::Helpers

class User
  include MongoMapper::Document

  key :username, String, :required => true, :length => 3..50, :unique => true
  key :locals,   String, :default => "en"
  key :hash,     String, :required => true
  key :salt,     String, :required => true

  many :games

  timestamps!
end

class Question
  include MongoMapper::EmbeddedDocument

  attr_accessor :mystery_text, :correct

  key  :mystery,          String,  :required => true # aka nutrition name to guess
  key  :question_text,    String,  :required => true
  key  :higher,           Boolean, :required => true
  key  :answered_correct, Boolean
  key  :product_ids,      Array

  many :products, :in => :product_ids

  embedded_in :game

  def generate_new_question_with_random_products_and_mystery
    new_question = Question.new

    #TODO: check on the same Product
    new_question.products << Product.new.random
    new_question.products << Product.new.random

    #TODO: check on the same nutrition value
    array_one = new_question.products[0].nutritions.delete_if{ |n| n.quantity.nil? }.map { |nutritions| nutritions.name  }
    array_two = new_question.products[1].nutritions.delete_if{ |n| n.quantity.nil? }.map { |nutritions| nutritions.name  }
    array_union = array_one & array_two

    random_mystery = array_union[rand(array_union.length)]

    new_question.mystery = random_mystery

    key = random_mystery.sub('davon ', '').sub('Energiewert', 'Kilokalorien').sub(' ', '')
    new_question.mystery_text = t.nutrition[key.to_sym]

    new_question.higher = [true, false][rand(2)]

    if new_question.higher
      comparisonText = t.nutrition.higherText
    else
      comparisonText = t.nutrition.lowerText
    end

    new_question.question_text = "#{comparisonText} #{new_question.mystery_text}?"

    new_question
  end

  def to_json(*a)
    {
      :id => _id,
      :question_text => question_text,
      :products => products.map { |prod| prod.to_json },
      :answered_correct => answered_correct
    }.to_json(*a)
  end
end

class Game
  include MongoMapper::Document

  attr_accessor :points

  key        :points, Integer, :numeric => true, :default => 0
  many       :questions # Array of 12 questions as MongoMapper::EmbeddedDocument
  belongs_to :user
  timestamps!


  def generate_new_game_with_random_questions
    random_question = Array.new(12).map { |x| Question.new.generate_new_question_with_random_products_and_mystery }
    Game.new(:questions => random_question)
  end

  def to_json(*a)
    {
      :id => _id,
      :points => points,
      :questions => questions.map { |question| question.to_json }
    }.to_json(*a)
  end
end

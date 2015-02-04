require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class SmokeTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def test_hompage_is_up_and_running_200
    get "/"
    assert last_response.ok?
  end

  def test_random_crap_fails
    get "/lol/catpoop.php"
    assert !last_response.ok?
  end

  #def test_setlocal
  #  get '/setlocals/de'
  #  follow_redirect!
  #
  #  # fix test with session
  #  assert_equal 'de', app.inspect
  #  assert last_response.ok?
  #end
end

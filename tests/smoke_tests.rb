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

  def test_setlocal
    get '/setlocals/de'
    follow_redirect!

    # fix test with session
    #assert_equal 'de', session
    assert last_response.ok?
  end

  def test_js
    get '/scripts.js'

    assert last_response.ok?
    assert_equal 'application/javascript;charset=utf-8', last_response.headers['Content-Type']
  end

  def test_json_play_nologin
    #redirect to / if user is not logedin
    get '/json/play'

    assert_equal 302, last_response.status
  end

  def test_json_play_withlogin
    #redirect to / if user is not logedin
    #get '/json/play', {}, 'rack.session' => { :username => 'foo' }

    #assert last_response.ok?
  end
end

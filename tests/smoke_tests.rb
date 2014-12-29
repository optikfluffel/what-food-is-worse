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
end

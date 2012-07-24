require 'test_helper'

class DevServerTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Iridium::DevServer.new.app
  end

  def setup
    Iridium.application = TestApp.instance
  end

  def test_it_should_serve_the_root
    get '/'

    assert last_response.ok?
  end

  def test_returns_not_found
    get '/foo/bars.js'

    assert_equal 404, last_response.status
  end
end

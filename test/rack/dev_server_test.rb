require 'test_helper'

class DevServerTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Iridium::DevServer.new.app
  end

  def test_returns_not_found
    get '/foo/bars.js'

    assert_equal 404, last_response.status
  end

  def test_pipeline
    create_file "app/javascripts/foo.js", "bar"

    get '/application.js'

    assert last_response.ok?

    assert_includes last_response.body, "bar"
  end

  def test_files_outside_the_pipeline_are_accessible
    create_file "site/images/sprite.png", "png"

    get '/images/sprite.png'

    assert last_response.ok?
  end
end

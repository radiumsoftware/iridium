require 'test_helper'

class DevServerTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Iridium::DevServer.new.app
  end

  def test_it_should_serve_the_root
    get '/'

    assert last_response.ok?
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

  def test_index_file_in_pipeline_overrides_default
    create_file "app/public/index.html", "bar"

    get '/'

    assert last_response.ok?

    assert_equal "bar", last_response.body.chomp
  end
end

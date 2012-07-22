require 'test_helper'
require 'fileutils'

class RackTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestApp
  end

  def site_path
    Pathname.new(File.expand_path('../app/site', __FILE__))
  end

  def create(path, content)
    File.open site_path.join(path), 'w+' do |f|
      f.puts content
    end
  end

  def setup
    TestApp.config.perform_caching = true
    FileUtils.mkdir_p site_path
  end

  def teardown
    FileUtils.rm_rf site_path
    TestApp.config.perform_caching = false
  end

  def test_serves_index_from_root
    create 'index.html', 'foo'

    get '/'

    assert last_response.ok?

    assert_equal 'foo', last_response.body.chomp
  end

  def test_adds_the_last_modified_header_to_assets
    create 'foo.html', 'bar'

    get '/foo.html'

    assert last_response.ok?

    mtime = File.new(site_path.join('foo.html')).mtime.httpdate
    assert_equal mtime, last_response.headers['Last-Modified']
  end

  def test_sets_the_cache_control_headers
    app.config.cache_control = "public, max-age=1965"
    create 'foo.html', 'bar'

    get "/foo.html"

    assert last_response.ok?
    assert_equal "public, max-age=1965", last_response.headers['Cache-Control']
  end

  def tests_returns_304_when_cache_matchs
    app.config.cache_control = "public"
    create 'foo.html', 'bar'

    get "/foo.html"

    assert last_response.ok?

    timestamp = last_response.headers['Last-Modified']

    assert timestamp

    get "/foo.html", {}, { "HTTP_IF_MODIFIED_SINCE" => timestamp }

    assert 304, last_response.status
  end
end

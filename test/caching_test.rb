require 'test_helper'
require 'fileutils'

class CachingTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestApp
  end

  def setup
    TestApp.config.perform_caching = true
    TestApp.config.cache = { 
      :entitystore => 'heap:/',
      :metastore => 'heap:/'
    }

    FileUtils.rm_rf TestApp.root.join("site/")
    FileUtils.mkdir_p TestApp.root.join("site")
    FileUtils.touch TestApp.root.join("site", "foo.html")
  end

  def teardown
    FileUtils.rm_rf TestApp.root.join("site")
    TestApp.config.perform_caching = false
  end

  def test_adds_the_last_modified_header_to_assets
    get "/foo.html"

    assert last_response.ok?

    mtime = File.new(root.join("site", "foo.html")).mtime.httpdate
    assert_equal mtime, last_response.headers['Last-Modified']
  end

  def test_sets_the_cache_control_headers
    app.config.cache_control = "public, max-age=1965"

    get "/foo.html"

    assert last_response.ok?
    assert_equal "public, max-age=1965", last_response.headers['Cache-Control']
  end

  def tests_returns_304_when_cache_matchs
    app.config.cache_control = "public"

    get "/foo.html"

    assert last_response.ok?

    timestamp = last_response.headers['Last-Modified']

    assert timestamp

    get "/foo.html", {}, { "HTTP_IF_MODIFIED_SINCE" => timestamp }

    assert 304, last_response.status
  end

  def tests_returns_200_when_the_cache_is_stale
    app.config.cache_control = "public, must-revalidate"

    get "/foo.html"

    assert last_response.ok?

    timestamp = last_response.headers['Last-Modified']
    assert timestamp

    sleep 1

    FileUtils.touch root.join("site", "foo.html")

    refute_equal timestamp, File.new(root.join('site', 'foo.html')).mtime.httpdate

    get "/foo.html", {}, { "HTTP_IF_MODIFIED_SINCE" => timestamp }

    assert last_response.ok?, "Expected a 200, but was a #{last_response.status}"

    refute_equal timestamp, last_response.headers['Last-Modified']
  end

  private
  def root
    app.root
  end
end

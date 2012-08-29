require 'test_helper'
require 'fileutils'

class RackTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Iridium.application
  end

  def test_serves_index_from_root
    create_file 'site/index.html', 'foo'

    get '/'

    assert last_response.ok?

    assert_equal 'foo', last_response.body.chomp
  end

  def test_adds_the_last_modified_header_to_assets
    create_file 'site/foo.html', 'bar'

    get '/foo.html'

    assert last_response.ok?

    mtime = File.new(Iridium.application.site_path.join('foo.html')).mtime.httpdate
    assert_equal mtime, last_response.headers['Last-Modified']
  end

  def test_sets_the_cache_control_headers
    create_file 'site/foo.html', 'bar'

    get "/foo.html"

    assert last_response.ok?
    assert_equal "max-age=0, private, must-revalidate", last_response.headers['Cache-Control']
  end

  def tests_returns_304_when_cache_matchs
    create_file 'site/foo.html', 'bar'

    get "/foo.html"

    assert last_response.ok?

    timestamp = last_response.headers['Last-Modified']

    assert timestamp

    get "/foo.html", {}, { "HTTP_IF_MODIFIED_SINCE" => timestamp }

    assert 304, last_response.status
  end

  def test_returns_compressed_files_when_requested
    create_file "site/application.js.gz", 'gzipped'

    get '/application.js', {}, 'HTTP_ACCEPT_ENCODING' => 'gzip'

    assert last_response.ok?

    assert_equal "gzip", last_response.headers['Content-Encoding']
    assert_equal "gzipped", last_response.body.chomp
  end

  def test_serves_the_cache_manifest_correctly
    create_file "site/cache.manifest", "manifest"

    get '/cache.manifest'

    assert last_response.ok?

    assert_equal "text/cache-manifest", last_response.headers['Content-Type']
  end
end

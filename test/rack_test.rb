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

  def test_serves_a_generated_index_file_if_not_present
    get "/"

    assert last_response.ok?
  end

  def test_generated_index_can_be_cached
    get "/"

    assert last_response.ok?

    assert last_response.headers['ETag']
    assert_equal "max-age=0, private, must-revalidate", last_response.headers['Cache-Control']
  end

  def test_generated_index_contains_basic_assets
    get "/"

    assert_includes last_response.body, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes last_response.body, %Q{<script src="/application.js"></script>}
    assert_includes last_response.body, %Q{minispade.require("test_app/boot");}
  end

  def test_returns_compressed_files_when_requested
    create_file "site/application.js.gz", 'gzipped'

    get '/application.js', {}, 'HTTP_ACCEPT_ENCODING' => 'gzip'

    assert last_response.ok?

    assert_equal "gzip", last_response.headers['Content-Encoding']
    assert_equal "gzipped", last_response.body.chomp
  end
end

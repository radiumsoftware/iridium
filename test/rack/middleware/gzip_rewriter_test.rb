require 'test_helper'
require 'fileutils'

class GzipRewriterTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    backend = Rack::Directory.new(TestApp.instance.site_path)
    Iridium::Rack::Middleware::GzipRewriter.new backend, TestApp.instance
  end

  def setup
    super
    create_file "site/application.js", "ungzipped"
    create_file "site/application.js.gz", "gzipped"
  end

  def test_returns_the_gzip_file_when_present_and_requested
    get '/application.js', {}, 'HTTP_ACCEPT_ENCODING' => 'gzip'

    assert last_response.ok?

    assert_equal 'gzip', last_response.headers['Content-Encoding']
    assert_equal 'gzipped', last_response.body.chomp
  end

  def test_returns_uncompressed_file_when_not_requested
    get '/application.js'

    assert last_response.ok?

    assert_equal 'ungzipped', last_response.body.chomp
  end
end

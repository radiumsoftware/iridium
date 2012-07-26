require 'test_helper'
require 'fileutils'

class DefaultIndexTest < MiniTest::Unit::TestCase
  def setup
    @app = MiniTest::Mock.new
    @middleware = Iridium::Middleware::DefaultIndex.new app, TestApp.instance
  end

  def test_index_returns_a_correct_response
    status, headers, body = middleware.call 'PATH_INFO' => '/index.html'

    assert_equal 200, status

    assert_equal 'text/html', headers['Content-Type']
  end

  def test_index_loads_standard_assets
    status, headers, body = middleware.call 'PATH_INFO' => '/index.html'

    body = body.map(&:to_s).join("")

    assert_includes body, %q{<script src="/application.js"></script>}
    assert_includes body, %q{<link href="/application.css" rel="stylesheet">}
  end

  def test_index_boots_the_app
    status, headers, body = middleware.call 'PATH_INFO' => '/index.html'

    body = body.map(&:to_s).join("")

    assert_includes body, %q{minispade.require("test_app/app");}
  end

  def test_skips_requests_other_than_index
    app.expect :call, [], [{'PATH_INFO' => 'foo.jpg'}]

    middleware.call 'PATH_INFO' => 'foo.jpg'

    app.verify
  end

  def test_skips_requests_when_there_is_an_index_file
    FileUtils.mkdir_p TestApp.instance.app_path.join('public')
    FileUtils.touch TestApp.instance.app_path.join('public', 'index.html')

    app.expect :call, [], [{'PATH_INFO' => 'foo.jpg'}]

    middleware.call 'PATH_INFO' => 'foo.jpg'

    FileUtils.rm_rf TestApp.instance.app_path.join('public')

    app.verify
  end

  private
  def app
    @app
  end

  def middleware
    @middleware
  end
end

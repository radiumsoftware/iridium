require 'test_helper'

class DevServerTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Iridium::DevServer.new.app
  end

  def setup
    @created_files = []
    Iridium.application = TestApp.instance
  end

  def teardown
    FileUtils.rm_rf TestApp.root.join("app")
    FileUtils.rm_rf TestApp.root.join("site")
    FileUtils.rm_rf TestApp.root.join("tmp")

    @created_files.each do |path|
      FileUtils.rm_rf path
    end
  end

  def test_it_should_serve_the_root
    get '/'

    assert last_response.ok?

    assert_equal 'text/html', last_response.headers['Content-Type']
  end

  def test_returns_not_found
    get '/foo/bars.js'

    assert_equal 404, last_response.status
  end

  def test_pipeline
    create_file "javascripts/foo.js", "bar"

    get '/application.js'

    assert last_response.ok?

    assert_includes last_response.body, "bar"
  end

  def test_index_file_in_pipeline_overrides_default
    create_file "public/index.html", "bar"

    get '/'

    assert last_response.ok?

    assert_equal "bar", last_response.body.chomp
  end

  private
  def create_file(path, content)
    full_path = TestApp.root.join "app", path

    @created_files << full_path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end
end

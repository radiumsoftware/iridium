require 'simplecov'
SimpleCov.start

require 'minitest/unit'
require 'minitest/pride'
require 'minitest/autorun'

require 'mocha'

require 'rack/test'

require 'iridium'

require 'debugger'

require 'webmock/minitest'

WebMock.disable_net_connect!

ENV['IRIDIUM_ENV'] = 'test'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |file|
  require file
end

# Require the test app which lives in a separate directory
require File.expand_path("../app/application", __FILE__)

class MiniTest::Unit::TestCase

  INDEX_FILE_PATH = File.expand_path("../../generators/iridium/application/templates/app/assets/index.html.erb.tt", __FILE__)

  def setup
    FileUtils.mkdir_p sandbox_path

    Iridium.application = TestApp.instance

    FileUtils.mkdir_p Iridium.application.app_path
    FileUtils.mkdir_p Iridium.application.site_path
    FileUtils.mkdir_p Iridium.application.tmp_path
    FileUtils.mkdir_p Iridium.application.vendor_path.join("javascripts")
    FileUtils.mkdir_p Iridium.application.vendor_path.join("stylesheets")
    FileUtils.mkdir_p Iridium.application.root.join('test', 'support')
    FileUtils.mkdir_p Iridium.application.root.join('external')

    ENV['IRIDIUM_ENV'] = 'test'
  end

  def teardown
    if Iridium.application && Iridium.application.is_a?(Iridium::Application)
      Iridium.application.config.scripts.clear
      Iridium.application.config.dependencies.clear
      Iridium.application.config.js_pipelines.clear
      Iridium.application.config.css_pipelines.clear
      Iridium.application.config.optimization_pipelines.clear

      FileUtils.rm_rf Iridium.application.app_path
      FileUtils.rm_rf Iridium.application.root.join("config")
      FileUtils.rm_rf Iridium.application.site_path
      FileUtils.rm_rf Iridium.application.tmp_path
      FileUtils.rm_rf Iridium.application.vendor_path
      FileUtils.rm_rf Iridium.application.build_path
      FileUtils.rm_rf Iridium.application.root.join("test")
      FileUtils.rm_rf Iridium.application.root.join("Assetfile") if File.exists?(Iridium.application.root.join('Assetfile'))
      FileUtils.rm_rf Iridium.application.root.join('external')
    end

    Iridium.application = nil

    FileUtils.rm_rf sandbox_path
  end

  def create_file(path, content)
    full_path = Iridium.application.root.join path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end

  def assert_file(path)
    full_path = Iridium.application.root.join path

    assert File.exists?(full_path), 
      "#{full_path} should be a file. Current Files: #{Dir[Iridium.application.root.join("**", "*").inspect]}"
  end

  def refute_file(path)
    full_path = Iridium.application.root.join path

    refute File.exists?(full_path), "#{full_path} should not be a file."
  end

  def fixtures_path
    Pathname.new(File.expand_path "../fixtures", __FILE__)
  end

  def fixture(*path)
    File.read fixtures_path.join(*path)
  end

  def read(*path)
    File.read Iridium.application.root.join(*path)
  end

  def sandbox_path
    Pathname.new(File.expand_path('../sandbox', __FILE__))
  end
end

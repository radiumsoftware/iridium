require 'simplecov'
SimpleCov.start

require 'minitest/unit'
require 'minitest/pride'
require 'minitest/autorun'

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
  def setup
    Iridium.application = TestApp.instance
    Iridium.application.site_path = Iridium.application.root.join("site")

    FileUtils.mkdir_p Iridium.application.app_path
    FileUtils.mkdir_p Iridium.application.site_path
    FileUtils.mkdir_p Iridium.application.tmp_path
    FileUtils.mkdir_p Iridium.application.vendor_path.join("javascripts")
    FileUtils.mkdir_p Iridium.application.vendor_path.join("stylesheets")
    FileUtils.mkdir_p Iridium.application.root.join('test', 'support')

    ENV['IRIDIUM_ENV'] = 'test'
  end

  def teardown
    if Iridium.application
      Iridium.application.config.scripts.clear
      Iridium.application.config.dependencies.clear

      FileUtils.rm_rf Iridium.application.app_path
      FileUtils.rm_rf Iridium.application.site_path
      FileUtils.rm_rf Iridium.application.tmp_path
      FileUtils.rm_rf Iridium.application.vendor_path
      FileUtils.rm_rf Iridium.application.root.join("test")
      FileUtils.rm_rf Iridium.application.root.join("Assetfile") if File.exists?(Iridium.application.root.join('Assetfile'))
    end
    Iridium.application = nil
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
end

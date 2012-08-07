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
    FileUtils.mkdir_p Iridium.application.root.join("app")
    FileUtils.mkdir_p Iridium.application.root.join("site")
    FileUtils.mkdir_p Iridium.application.root.join("tmp")
    FileUtils.mkdir_p Iridium.application.root.join("test")
    FileUtils.mkdir_p Iridium.application.root.join('test', 'support')
  end

  def teardown
    if Iridium.application
      Iridium.application.config.dependencies.clear
      FileUtils.rm_rf Iridium.application.root.join("app")
      FileUtils.rm_rf Iridium.application.root.join("Assetfile") if File.exists?(Iridium.application.root.join('Assetfile'))
      FileUtils.rm_rf Iridium.application.root.join("site")
      FileUtils.rm_rf Iridium.application.root.join("tmp")
      FileUtils.rm_rf Iridium.application.root.join("test")
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

  def read(*path)
    File.read Iridium.application.root.join(*path)
  end
end

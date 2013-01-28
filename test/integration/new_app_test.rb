require 'test_helper'
require 'iridium/cli'

# NOTE: Make sure each generated app is unique so it can be required
# and the inherited callback will hit. This makes things work as expected
class NewAppTest < MiniTest::Unit::TestCase
  def setup
    super
    FileUtils.rm_rf sandbox_path
    FileUtils.mkdir_p sandbox_path
  end

  def sandbox_path
    Pathname.new(File.expand_path('../../sandbox/test_app', __FILE__))
  end

  def generate_app(name)
    Dir.chdir sandbox_path do
      capture_io do
        Iridium::CLI.new.invoke :generate, ['app', name]
      end
    end

    assert File.directory?(sandbox_path.join(name)), "App not generated!"
  end

  def test_new_qunit_apps_are_tested_correctly
    generate_app "todos_qunit"

    Iridium.application = nil

    require sandbox_path.join("todos_qunit").join("config", "environment")

    assert Iridium.application

    Dir.chdir sandbox_path.join('todos_qunit') do
      result = nil

      Iridium.application.config.pipeline.compile_tests = true
      Iridium.application.compile

      parts = []

      parts << 'phantomjs'
      parts << %Q{"#{Iridium.phantom_js_test_runner}"}
      parts << %Q{"#{Iridium.application.site_path}/tests.html"}

      command = parts.join " "

      output = `#{command}`

      assert $?.success?, "Release blocker! Tests failed!"
    end
  end

  def test_new_jasmine_apps_are_tested_correctly
    generate_app "todos_jasmine"

    Iridium.application = nil

    require sandbox_path.join("todos_jasmine").join("config", "environment")

    assert Iridium.application

    Dir.chdir sandbox_path.join('todos_jasmine') do
      result = nil

      Iridium.application.config.pipeline.compile_tests = true
      Iridium.application.compile

      parts = []

      parts << 'phantomjs'
      parts << %Q{"#{Iridium.phantom_js_test_runner}"}
      parts << %Q{"#{Iridium.application.site_path}/tests.html"}

      command = parts.join " "

      output = `#{command}`

      assert $?.success?, "Release blocker! Tests failed!"
    end
  end

  def test_app_works_works_in_development
    generate_app "dev_test"

    Iridium.application = nil

    Dir.chdir sandbox_path.join('dev_test') do
      Iridium::Pipeline::CompileCommand.new.invoke :compile, [], :environment => "development"
    end
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_app_works_works_in_test
    generate_app "test_test"

    Iridium.application = nil

    Dir.chdir sandbox_path.join('test_test') do
      Iridium::Pipeline::CompileCommand.new.invoke :compile, [], :environment => "test"
    end
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_app_works_works_in_production
    generate_app "production_test"

    Iridium.application = nil

    Dir.chdir sandbox_path.join('production_test') do
      Iridium::Pipeline::CompileCommand.new.invoke :compile, [], :environment => "production"
    end
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end
end

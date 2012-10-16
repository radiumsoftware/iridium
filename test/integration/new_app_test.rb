require 'test_helper'

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

  def test_new_apps_are_tested_correctly
    generate_app "todos"

    Iridium.application = nil

    require sandbox_path.join("todos").join("application")

    assert Iridium.application

    Dir.chdir sandbox_path.join('todos') do
      # have to explicitly declare test files because default ARGV
      test_files = Dir['test/**/*_test.{coffee,js}']

      result = nil

      stdout, stderr = capture_io do
        result = Iridium::Testing::Suite.execute test_files
      end

      refute_equal 1, result, "RELEASE BLOCKER: Tests failed: #{stdout}"
      refute_equal 2, result, "RELEASE BLOCKER: Test suite failed to start: #{stderr}"
      assert_equal 0, result

      assert_empty stderr
      assert_includes stdout, "2 Test(s)"
      assert_includes stdout, "0 Error(s)"
      assert_includes stdout, "0 Failure(s)"
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

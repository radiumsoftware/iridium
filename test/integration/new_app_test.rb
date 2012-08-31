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

  def test_new_apps_are_tested_correctly
    Dir.chdir sandbox_path do
      capture_io { Iridium::CLI.start %w(app todos) }

      assert File.directory?('todos'), "App not generated!"
    end

    Iridium.application = nil

    Dir.chdir sandbox_path.join('todos') do
      # have to explicitly declare test files because default ARGV
      test_files = Dir['test/**/*_test.{coffee,js}']

      result = nil

      stdout, stderr = capture_io do
        result = Iridium::Commands::Test.start test_files
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
    Dir.chdir sandbox_path do
      capture_io { Iridium::CLI.start %w(app dev_test) }

      assert File.directory?('dev_test'), "App not generated!"
    end

    Iridium.application = nil

    Dir.chdir sandbox_path.join('dev_test') do
      runner = Iridium::CLI.new [], :environment => 'development'
      runner.invoke :compile
    end
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_app_works_works_in_test
    Dir.chdir sandbox_path do
      capture_io { Iridium::CLI.start %w(app test_test) }

      assert File.directory?('test_test'), "App not generated!"
    end

    Iridium.application = nil

    Dir.chdir sandbox_path.join('test_test') do
      runner = Iridium::CLI.new [], :environment => 'test'
      runner.invoke :compile
    end
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_app_works_works_in_production
    Dir.chdir sandbox_path do
      capture_io { Iridium::CLI.start %w(app production_test) }

      assert File.directory?('production_test'), "App not generated!"
    end

    Iridium.application = nil

    Dir.chdir sandbox_path.join('production_test') do
      runner = Iridium::CLI.new [], :environment => 'production'
      runner.invoke :compile
    end
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end
end

require 'test_helper'

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

    Iridium.application = nil # so the new app is loaded

    Dir.chdir sandbox_path.join('todos') do
      # have to explicitly declare test files because default ARGV
      test_files = Dir['test/**/*_test.{coffee,js}']

      result = nil

      stdout, stderr = capture_io do
        result = Iridium::Commands::Test.start test_files
      end

      assert_equal 0, result, "RELEASE BLOCKER: Tests failed for some reason!\n#{stdout}"

      assert_empty stderr
      assert_includes stdout, "2 Test(s)"
      assert_includes stdout, "0 Error(s)"
      assert_includes stdout, "0 Failure(s)"
    end
  end
end

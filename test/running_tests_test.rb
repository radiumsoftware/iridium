require 'test_helper'
require 'iridium/commands/test'

class RunningTestsTest < MiniTest::Unit::TestCase
  def setup
    Iridium.application = TestApp.instance
  end

  def teardown
    Iridium.application = nil
    FileUtils.rm_rf TestApp.root.join("app")
    FileUtils.rm_rf TestApp.root.join("site")
    FileUtils.rm_rf TestApp.root.join("tmp")
    FileUtils.rm_rf TestApp.root.join("test")
  end

  def test_raises_an_error_if_file_does_not_exist
    stdout, stderr = invoke "foo.js"

    assert_includes stderr, "foo.js"
  end

  # def test_runs_a_unit_test_in_javascript
  #   create_file "test/unit/truth_test.js", <<-test
  #     test('Truth', function() {
  #       ok(true, "Passed!")
  #     });
  #   test

  #   stdout, stderr = invoke "test/unit/truth_test.js"

  #   assert_includes "1 Test(s)", stdout
  # end

  def invoke(*args)
    capture_io do
      Dir.chdir Iridium.application.root do
        Iridium::Commands::Test.start(args)
      end
    end
  end

  private
  def create_file(path, content)
    full_path = TestApp.root.join path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end
end

require 'test_helper'

class TestSuiteTest < MiniTest::Unit::TestCase
  class MockTest
    def initialize(result)
      @result = result
    end

    def run(options = {})
      [@result]
    end
  end

  def mock_test
    MockTest.new(Iridium::TestResult.new(:passed => true))
  end

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

  def tests_compiles_the_pipline
    create_file "app/javascripts/foo.js", "foo"
    create_file "test/unit/basic_test.js", "foo"

    start

    assert_file "application.js"
  end

  def test_prepares_a_directory_for_unit_tests
    create_file "test/unit/basic_test.js", "foo"
    create_file "test/models/advanced_test.js", "foo"

    start

    assert_file "test/unit/basic_test.js"
    assert_file "test/models/advanced_test.js"
  end

  def test_compiles_coffeescript_unit_tests_to_javascript
    create_file "test/unit/truth_test.coffee", <<-str
      test 'Truth', -> 
        ok true, "Passed!"
    str

    start

    assert_file "test/unit/truth_test.js"
  end

  def test_copies_support_files
    create_file "test/support/foo.js", "foo"
    create_file "test/unit/foo_test.js", "bar"

    start

    assert_file "test/support/foo.js"
  end

  def test_support_coffee_script_files_are_compiled_to_js
    create_file "test/support/foo.coffee", "foo"
    create_file "test/unit/foo_test.js", "bar"

    start

    assert_file "test/support/foo.js"
  end

  def test_suite_collects_results_from_tests
    results = start mock_test, mock_test

    assert_equal 2, results.size
  end

  private
  def destination_root
    Iridium.application.root.join('tmp', 'test_root')
  end

  def assert_file(*path)
    full_path = destination_root.join *path

    assert File.exists?(full_path), 
      "#{full_path} should be a file. Current Files: #{Dir[destination_root.join("**", "*").inspect]}"
  end

  def root
    Iridium.application.root
  end

  def start(*test_files)
    options = test_files.extract_options!
    capture_io { Iridium::TestSuite.new(Iridium.application, test_files).run(options) }
  end

  def create_file(path, content)
    full_path = TestApp.root.join path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end
end

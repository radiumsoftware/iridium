require 'test_helper'

class TestSuiteTest < MiniTest::Unit::TestCase
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

    start root.join("test/unit/basic_test.js"), :dry_run => true

    assert_file "application.js"
  end

  def test_prepares_a_directory_for_unit_tests
    create_file "test/unit/basic_test.js", "foo"
    create_file "test/models/advanced_test.js", "foo"

    start root.join("test/unit/basic_test.js"), root.join("test/models/advanced_test.js"), :dry_run => true

    assert_file "test/unit/basic_test.js"
    assert_file "test/models/advanced_test.js"
  end

  def test_compiles_coffeescript_unit_tests_to_javascript
    create_file "test/unit/truth_test.coffee", <<-str
      test 'Truth', -> 
        ok true, "Passed!"
    str

    start root.join("unit/truth_test.coffee"), :dry_run => true

    assert_file "test/unit/truth_test.js"
  end

  def test_copies_support_files
    create_file "test/support/foo.js", "foo"
    create_file "test/unit/foo_test.js", "bar"

    start root.join("unit/foo_test.js"), :dry_run => true

    assert_file "test/support/foo.js"
  end

  def test_support_coffee_script_files_are_compiled_to_js
    create_file "test/support/foo.coffee", "foo"
    create_file "test/unit/foo_test.js", "bar"

    start root.join("unit/foo_test.js"), :dry_run => true

    assert_file "test/support/foo.js"
  end

  def test_runs_a_unit_test
    create_file "test/unit/truth_test.coffee", <<-str
      test 'Truth', -> 
        ok true, "Passed!"
    str

    start root.join("unit/truth_test.coffee")
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
    Iridium::TestSuite.new(Iridium.application, test_files, options).run
  end

  def create_file(path, content)
    full_path = TestApp.root.join path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end
end

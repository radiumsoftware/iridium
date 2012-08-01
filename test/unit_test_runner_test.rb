require 'test_helper'

class UnitTestRunnerTest < MiniTest::Unit::TestCase
  def setup
    Iridium.application = TestApp.instance
    Iridium.application.config.load :qunit
    FileUtils.mkdir_p working_directory
    File.open working_directory.join("qunit.js"), "w" do |qunit|
      qunit.puts File.read(File.expand_path('../../generators/application/app/dependencies/qunit.js', __FILE__))
    end
    create_file "application.js", <<-file
      var foo = {};
    file
  end

  def teardown
    Iridium.application.config.dependencies.clear
    FileUtils.rm_rf working_directory
    Iridium.application = nil
  end

  def working_directory
    Iridium.application.root.join('tmp', 'test_root')
  end

  def create_file(path, content)
    full_path = working_directory.join path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end

  def read(path)
    File.read working_directory.join(path)
  end

  def invoke(*files)
    options = files.extract_options!
    results = nil

    out, err = capture_io do
      results = Iridium::UnitTestRunner.new(Iridium.application, files).run(options)
    end

    [results, out, err]
  end

  def test_raises_an_error_when_file_is_missing
    create_file "example_test.js", "foo"

    assert_raises RuntimeError do
      invoke "foo.js", :dry_run => true
    end
  end

  def test_runner_generates_the_loader_correctly
    create_file "test/support/example.js", "foo"
    create_file "truth.js", "foo"
    create_file "foo/bar.js", "bar"

    invoke "truth.js", "foo/bar.js", :dry_run => true

    test_loader = Dir[working_directory.join("**/*")].select { |f| f =~ /unit_test_runner.+\.html/ }.first
    assert test_loader, "Could not find a loader!"

    content = read File.basename(test_loader)

    assert_includes content, %Q{<script src="application.js"></script>}
    assert_includes content, %Q{<script src="truth.js"></script>}
    assert_includes content, %Q{<script src="foo/bar.js"></script>}

    assert_includes content, %Q{<script src="qunit.js"></script>}, "Dependencies should be included!"

    assert_includes content, %Q{<script src="test/support/example.js"></script>}, "Support files should be included!"
  end

  def test_captures_basic_test_information
    create_file "truth_test.js", <<-test
      test('Truth', function() {
        ok(false, "Passed!")
      });
    test

    results, stdout, stderr = invoke "truth_test.js"
    test_result = results.first
    assert_equal "Truth", test_result.name
    assert_kind_of Fixnum, test_result.time
    assert_equal 1, test_result.assertions
  end

  def test_reports_passes
    create_file "truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    results, stdout, stderr = invoke "truth_test.js"
    test_result = results.first
    assert test_result.passed?
    assert_equal 1, test_result.assertions
  end

  def test_reports_assertion_errors
    create_file "failed_assertion.js", <<-test
      test('Failed Assertions', function() {
        ok(false, "failed");
      });
    test

    results, stdout, stderr = invoke "failed_assertion.js"
    test_result = results.first
    assert test_result.failed?
    assert_equal "failed", test_result.message
    assert test_result.backtrace
    assert_equal 1, test_result.assertions
  end

  def test_reports_expectation_errors
    create_file "failed_expectation.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    results, stdout, stderr = invoke "failed_expectation.js"
    test_result = results.first
    assert test_result.failed?
    assert_match test_result.message, /expect/i
    assert_match test_result.message, /0/
    assert_match test_result.message, /1/
    assert test_result.backtrace
    assert_equal 1, test_result.assertions
  end

  def test_reports_errors
    create_file "error.js", <<-test
      test('This test has invalid js', function() {
        foobar();
      });
    test

    results, stdout, stderr = invoke "error.js"
    test_result = results.first
    assert test_result.error?
    assert test_result.backtrace
    assert_equal 0, test_result.assertions
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
  end

  def tests_reports_multiple_tests
    create_file "failed_expectation.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    create_file "truth_test.js", <<-test
      test('Truth', function() {
        ok(false, "Passed!")
      });
    test

    results, stdout, stderr = invoke "failed_expectation.js", "truth_test.js"

    assert_equal 2, results.size
  end

  def test_dry_run_returns_no_results
    create_file "foo.js", "bar"

    results, stdout, stderr = invoke "foo.js", :dry_run => true

    assert_equal [], results
  end

  def test_debug_mode_prints_to_stdout
    create_file "foo.js", <<-test
      test('Truth', function() {
        console.log("This is logged!");
      });
    test

    results, stdout, stderr = invoke "foo.js", :debug => true

    assert_includes stdout, "This is logged!"
  end

  def test_returns_an_error_if_a_local_script_cannot_be_loaded
    create_file "truth.js", <<-test
      test('Truth', function() {
        setTimeout(function() {}, 5000);
      });
    test

    Iridium.application.config.load :unknown_file

    results, stdout, stderr = invoke "truth.js"

    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal 0, test_result.assertions
    assert_includes test_result.message, "unknown_file.js"
  end

  def test_returns_an_error_if_an_remote_script_cannot_be_loaded
    create_file "truth.js", <<-test
      test('Truth', function() {
        setTimeout(function() {}, 5000);
      });
    test

    Iridium.application.config.load "http://www.google.com/plop/jquery-2348917.js"

    results, stdout, stderr = invoke "truth.js"

    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal 0, test_result.assertions
    assert_includes test_result.message, "http://www.google.com/plop/jquery-2348917.js"
  end

  def test_returns_an_error_when_the_test_file_is_bad
    create_file "undefined.js", <<-test
      var baz = foo + bar;
    test

    results, stdout, stderr = invoke "undefined.js"

    assert_equal 1, results.size
    test_result = results.first
    refute test_result.passed?
    assert test_result.message
    assert test_result.backtrace
  end
end

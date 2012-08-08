require 'test_helper'

class UnitTestRunnerTest < MiniTest::Unit::TestCase
  def setup
    super

    Iridium.application.config.load :minispade

    File.open Iridium.application.root.join('test', 'support', 'qunit.js'), "w" do |qunit|
      qunit.puts File.read(File.expand_path("../fixtures/qunit.js", __FILE__))
    end

    File.open Iridium.application.site_path.join("minispade.js"), "w" do |file|
      file.puts File.read(File.expand_path('../fixtures/minispade.js', __FILE__))
    end

    File.open Iridium.application.site_path.join('application.js'), "w" do |file|
      file.puts <<-code
        minispade.register('test_app/app', function() { 
          window.appLoaded = true;
        })
      code
    end
  end

  def test_helper
    <<-str
      class Helper
        scripts: [
          'support/qunit'
          'iridium/qunit_adapter'
        ]

        iridium: ->
          _iridium = requireExternal('iridium').create()
          _iridium.scripts = @scripts
          _iridium

      exports.casper = ->
        (new Helper).iridium().casper()
    str
  end

  def invoke(*files)
    options = files.extract_options!
    results = nil

    out, err = capture_io do
      Dir.chdir Iridium.application.root do
        results = Iridium::UnitTestRunner.new(Iridium.application, files).run(options)
      end
    end

    [results, out, err]
  end

  def test_raises_an_error_when_file_is_missing
    create_file "test/helper.coffee", test_helper
    create_file "test/example_test.js", "foo"

    assert_raises RuntimeError do
      invoke "test/foo.js", :dry_run => true
    end
  end

  def test_captures_basic_test_information
    create_file "test/helper.coffee", test_helper

    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(false, "Passed!")
      });
    test

    results, stdout, stderr = invoke "test/truth_test.js"
    assert_kind_of Array, results
    test_result = results.first
    assert_equal "Truth", test_result.name
    assert_kind_of Fixnum, test_result.time
    assert_equal 1, test_result.assertions
  end

  def test_reports_passes
    create_file "test/helper.coffee", test_helper

    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    results, stdout, stderr = invoke "test/truth_test.js"
    assert_kind_of Array, results
    test_result = results.first
    assert test_result.passed?
    assert_equal 1, test_result.assertions
  end

  def test_reports_assertion_errors
    create_file "test/helper.coffee", test_helper

    create_file "test/failed_assertion.js", <<-test
      test('Failed Assertions', function() {
        ok(false, "failed");
      });
    test

    results, stdout, stderr = invoke "test/failed_assertion.js"
    assert_kind_of Array, results
    test_result = results.first
    assert test_result.failed?
    assert_equal "failed", test_result.message
    assert test_result.backtrace
    assert_equal 1, test_result.assertions
  end

  def test_reports_expectation_errors
    create_file "test/helper.coffee", test_helper

    create_file "test/failed_expectation.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    results, stdout, stderr = invoke "test/failed_expectation.js"
    assert_kind_of Array, results
    test_result = results.first
    assert test_result.failed?
    assert_match test_result.message, /expect/i
    assert_match test_result.message, /0/
    assert_match test_result.message, /1/
    assert test_result.backtrace
    assert_equal 1, test_result.assertions
  end

  def test_reports_errors
    create_file "test/helper.coffee", test_helper

    create_file "test/error.js", <<-test
      test('This test has invalid js', function() {
        foobar();
      });
    test

    results, stdout, stderr = invoke "test/error.js"
    assert_kind_of Array, results
    test_result = results.first
    assert test_result.error?
    assert test_result.backtrace
    assert_equal 0, test_result.assertions
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
  end

  def tests_reports_multiple_tests
    create_file "test/helper.coffee", test_helper

    create_file "test/failed_expectation.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(false, "Passed!")
      });
    test

    results, stdout, stderr = invoke "test/failed_expectation.js", "test/truth_test.js"

    assert_kind_of Array, results
    assert_equal 2, results.size
  end

  def test_dry_run_returns_no_results
    create_file "test/foo.js", "bar"

    results, stdout, stderr = invoke "test/foo.js", :dry_run => true

    assert_equal [], results
  end

  def test_debug_mode_prints_to_stdout
    create_file "test/helper.coffee", test_helper

    create_file "test/foo.js", <<-test
      test('Truth', function() {
        console.log("This is logged!");
      });
    test

    results, stdout, stderr = invoke "test/foo.js", :debug => true

    assert_includes stdout, "This is logged!"
  end

  def test_returns_an_error_if_a_local_script_cannot_be_loaded
    create_file "test/helper.coffee", test_helper

    create_file "test/truth.js", <<-test
      test('Truth', function() {
        setTimeout(function() {}, 5000);
      });
    test

    Iridium.application.config.load :unknown_file

    results, stdout, stderr = invoke "test/truth.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal 0, test_result.assertions
    assert_includes test_result.message, "unknown_file.js"
  end

  def test_returns_an_error_if_an_remote_script_cannot_be_loaded
    create_file "test/helper.coffee", test_helper

    create_file "test/truth.js", <<-test
      test('Truth', function() {
        setTimeout(function() {}, 5000);
      });
    test

    Iridium.application.config.load "http://www.google.com/plop/jquery-2348917.js"

    results, stdout, stderr = invoke "test/truth.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal 0, test_result.assertions
    assert_includes test_result.message, "http://www.google.com/plop/jquery-2348917.js"
  end

  def test_returns_an_error_when_the_test_file_is_bad
    create_file "test/helper.coffee", test_helper

    create_file "test/undefined.js", <<-test
      var baz = foo + bar;
    test

    results, stdout, stderr = invoke "test/undefined.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    refute test_result.passed?
    assert test_result.message
    assert test_result.backtrace
  end

  def test_one_test_cannot_bring_down_others
    create_file "test/helper.coffee", test_helper

    create_file "test/success.js", <<-test
      test('Truth', function() {
        ok(true, "passed");
      });
    test

    create_file "test/error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "test/error.js", "test/success.js", :debug => true

    assert_kind_of Array, results
    assert_equal 2, results.size
  end

  def test_raises_an_error_when_js_aborts
    create_file "test/helper.coffee", <<-str
      class Helper
        scripts: [
          'this_file_doesnt_exist'
        ]

        iridium: ->
          _iridium = requireExternal('iridium').create()
          _iridium.scripts = @scripts
          _iridium

      exports.casper = ->
        (new Helper).iridium().casper()
    str

    create_file "test/success.js", <<-test
      test('Truth', function() {
        ok(true, "passed");
      });
    test

    assert_raises Iridium::CommandStreamer::ProcessAborted do
      invoke "test/success.js"
    end
  end

  def test_app_module_is_required
    create_file "test/helper.coffee", test_helper
    create_file "test/module_test.coffee", <<-test
      test 'minispade modules are required', ->
        ok window.appLoaded, "test_app/app should be required!"
    test

    results, stdout, stderr = invoke "test/module_test.coffee"

    assert_kind_of Array, results
    assert_equal 1, results.size
    assert results.first.passed?
  end
end

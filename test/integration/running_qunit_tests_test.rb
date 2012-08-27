require 'test_helper'

class UnitTestRunnerTest < MiniTest::Unit::TestCase
  def create_loader
    # create this file so we can test qunit insolation. It's normally the 
    # test suite's responsiblity to ensure all the preconditions so we
    # take care of it ourselves in this case.
    File.open Iridium.application.site_path.join('unit_test_runner.html'), "w" do |file|
      template = <<-code
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>Unit Tests</title>

            <!--[if lt IE 9]>
              <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
            <![endif]-->
          </head>

          <body>
            <div id="place-holder"></div>
            <% Iridium.application.config.scripts.each do |script| %>
              <script src="<%= script %>"></script>
            <% end %>
          </body>
        </html>
      code

      file.puts ERB.new(template).result(binding)
    end
  end

  def setup
    super

    create_loader
  end

  def invoke(*files)
    options = files.extract_options!
    results = nil

    out, err = capture_io do
      Dir.chdir Iridium.application.root do
        results = Iridium::TestRunner.new(Iridium.application, files).run(options)
      end
    end

    [results, out, err]
  end

  def test_captures_basic_test_information
    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(false, "Passed!")
      });
    test

    results, stdout, stderr = invoke "test/truth_test.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert_equal "Truth", test_result.name
    assert_kind_of Fixnum, test_result.time
    assert_equal 1, test_result.assertions
    assert_equal "test/truth_test.js", test_result.file
  end

  def test_reports_passes
    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    results, stdout, stderr = invoke "test/truth_test.js"
    assert_equal 1, results.size
    assert_kind_of Array, results
    test_result = results.first
    assert test_result.passed?
    assert_equal 1, test_result.assertions
  end

  def test_reports_assertion_errors
    create_file "test/failed_assertion.js", <<-test
      test('Failed Assertions', function() {
        ok(false, "failed");
      });
    test

    results, stdout, stderr = invoke "test/failed_assertion.js"
    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.failed?
    assert_equal "failed", test_result.message
    assert test_result.backtrace
    assert_equal 1, test_result.assertions
  end

  def test_reports_expectation_errors
    create_file "test/failed_expectation.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    results, stdout, stderr = invoke "test/failed_expectation.js"
    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.failed?
    assert_match test_result.message, /expect/i
    assert_match test_result.message, /0/
    assert_match test_result.message, /1/
    assert test_result.backtrace
    assert_equal 1, test_result.assertions
  end

  def test_reports_errors
    create_file "test/error.js", <<-test
      test('This test has invalid js', function() {
        foobar();
      });
    test

    results, stdout, stderr = invoke "test/error.js"
    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert test_result.backtrace
    assert_equal 0, test_result.assertions
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
  end

  def tests_reports_multiple_tests
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

  def test_returns_an_error_if_a_local_script_cannot_be_loaded
    create_file "test/truth.js", <<-test
      test('Truth', function() {
        ok(true, "Truth!");
      });
    test

    Iridium.application.config.script "unknown_file.js"

    create_loader # call again to pull in new config

    results, stdout, stderr = invoke "test/truth.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal 0, test_result.assertions
    assert_includes test_result.message, "unknown_file.js"
  end

  def test_returns_an_error_if_an_remote_script_cannot_be_loaded
    create_file "test/truth.js", <<-test
      test('Truth', function() {
        ok(true, "Truth!");
      });
    test

    Iridium.application.config.script "http://www.google.com/plop/jquery-2348917.js"

    create_loader # call again to pull in new config

    results, stdout, stderr = invoke "test/truth.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal 0, test_result.assertions
    assert_includes test_result.message, "http://www.google.com/plop/jquery-2348917.js"
  end

  def test_returns_an_error_when_the_test_file_is_bad
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
    create_file "test/success.js", <<-test
      test('Truth', function() {
        ok(true, "passed");
      });
    test

    create_file "test/error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "test/error.js", "test/success.js"

    assert_kind_of Array, results
    assert_equal 2, results.size
  end

  def test_dom_content_is_not_wiped_out
    create_file "test/dom_test.js", <<-test
      test("Qunit adapter does not wipe the DOM", function() {
        ok(document.getElementById("place-holder"), "#place-holder should exist!");
      })
    test

    results, stdout, stderr = invoke "test/dom_test.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    result = results.first
    assert result.passed?
  end

  def test_qunit_div_is_added
    create_file "test/dom_test.js", <<-test
      test("qunit div is added", function() {
        ok(document.getElementById("qunit"), "#qunit should exist!");
      })
    test

    results, stdout, stderr = invoke "test/dom_test.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    result = results.first
    assert result.passed?
  end
end

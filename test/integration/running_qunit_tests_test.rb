require 'test_helper'

class UnitTestRunnerTest < PhantomJsTestCase
  def create_test_support_files
    # create this file so we can test qunit insolation. It's normally the 
    # test suite's responsiblity to ensure all the preconditions so we
    # take care of it ourselves in this case.
    File.open Iridium.application.test_path.join('framework', 'loader.html'), "w" do |file|
      template = <<-code
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>Unit Tests</title>

            <script src="tests.js" type="text/javascript"></script>
          </head>

          <body>
            <div id="application"></div>
          </body>
        </html>
      code

      file.puts ERB.new(template).result(binding)
    end

    qunit_path = File.expand_path "../../../generators/iridium/application/templates/test_frameworks/qunit/qunit.js", __FILE__

    FileUtils.cp qunit_path, "#{Iridium.application.test_path}/framework/qunit.js"
  end

  def test_captures_basic_test_information
    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(false, "Passed!")
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"

    assert_total_tests output, 1
    assert_total_failures output, 1
    assert_total_passes output, 0
  end

  def test_reports_passes
    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    output, status = invoke

    assert status.success?, "Tests should pass"

    assert_total_tests output, 1
    assert_total_failures output, 0
    assert_total_passes output, 1
  end

  def test_reports_assertion_errors
    create_file "test/failed_assertion_test.js", <<-test
      test('Failed Assertions', function() {
        ok(false, "Assertion message");
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
    assert_total_failures output, 1

    assert_includes output, "Assertion message"
  end

  def test_reports_expectation_errors
    create_file "test/failed_expectation_test.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
    assert_total_failures output, 1

    assert_includes output, "Expected 1 assertions, but 0 were run"
  end

  def test_reports_errors
    create_file "test/error_test.js", <<-test
      test('This test has invalid js', function() {
        foobar();
      });
    test

    output, status = invoke

    assert_total_failures output, 1

    assert_includes output, "ReferenceError: Can't find variable: foobar"
  end

  def tests_reports_multiple_tests
    create_file "test/failed_expectation_test.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    create_file "test/truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"

    assert_total_tests output, 2
    assert_total_passes output, 1
    assert_total_failures output, 1
  end

  def test_returns_an_error_when_the_test_file_is_bad
    create_file "test/undefined_test.js", <<-test
      var baz = foo + bar;
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
  end

  def test_dom_content_is_not_wiped_out
    create_file "test/dom_test.js", <<-test
      test("Qunit adapter does not wipe the DOM", function() {
        ok(document.getElementById("application"), "#application should exist!");
      })
    test

    output, status = invoke
    assert status.success?, "Tests should pass"
  end

  def test_qunit_div_is_added
    create_file "test/dom_test.js", <<-test
      test("qunit div is added", function() {
        ok(document.getElementById("qunit"), "#qunit should exist!");
      })
    test

    output, status = invoke
    assert status.success?, "Tests should pass"
  end

  def test_qunit_fixture_div_is_loaded
    create_file "test/qunit_fixture_test.js", <<-test
      test("qunit div is added", function() {
        ok(document.getElementById("qunit-fixture"), "#qunit-fixture should exist!");
      })
    test

    output, status = invoke
    assert status.success?, "Tests should pass"
  end

  def test_errors_in_setup_are_handled
    create_file "test/setup_test.js", <<-test
      module("foo", {
        setup: function() {
          fooBar();
        }
      });

      test("Truth", function() {
        ok(true, "True should be true!");
      })
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
    assert_includes output, "Setup failed"
  end

  def test_errors_in_teardown_are_handled
    create_file "test/teardown_test.js", <<-test
      module("foo", {
        teardown: function() {
          fooBar();
        }
      });

      test("Truth", function() {
        ok(true, "True should be true!");
      })
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
    assert_includes output, "Teardown failed"
  end

  def test_test_can_print_to_the_console
    create_file "test/logging_test.js", <<-test
      test("console is logged", function() {
        expect(0);
        console.log('logged');
      });
    test

    output, status = invoke

    refute_includes output, "logged"

    output, status = invoke "--debug"

    assert_includes output, "logged"
  end
end

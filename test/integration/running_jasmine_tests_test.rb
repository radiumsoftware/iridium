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
          </body>
        </html>
      code

      file.puts ERB.new(template).result(binding)
    end

    qunit_path = File.expand_path "../../../generators/iridium/application/templates/test_frameworks/jasmine/jasmine.js", __FILE__

    FileUtils.cp qunit_path, "#{Iridium.application.test_path}/framework/jasmine.js"
  end

  def test_captures_basic_test_information
    create_file "test/test_spec.js", <<-test
      describe("Tests", function() {
        it("should be true", function() {
          expect(false).toBe(true);
        });
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"

    assert_total_tests output, 1
    assert_total_failures output, 1
    assert_total_passes output, 0
  end

  def test_reports_passes
    create_file "test/test_spec.js", <<-test
      describe("Tests", function() {
        it("should be true", function() {
          expect(true).toBe(true);
        });
      });
    test

    output, status = invoke

    assert status.success?, "Tests should pass"

    assert_total_tests output, 1
    assert_total_failures output, 0
    assert_total_passes output, 1
  end

  def test_reports_assertion_errors
    create_file "test/test_spec.js", <<-test
      describe("Tests", function() {
        it("should be true", function() {
          expect(false).toBe(true);
        });
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
    assert_total_failures output, 1

    assert_includes output, "Expected false to be true"
  end

  def test_reports_errors
    create_file "test/test_spec.js", <<-test
      describe("Tests", function() {
        it("should be true", function() {
          fooBar();
        });
      });
    test

    output, status = invoke

    assert_total_failures output, 1

    assert_includes output, "ReferenceError: Can't find variable: fooBar"
  end

  def tests_reports_multiple_tests
    create_file "test/test_spec.js", <<-test
      describe("Tests", function() {
        it("should be true", function() {
          expect(true).toBe(true);
        });

        it("should be false", function() {
          expect(false).toBe(true);
        });
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"

    assert_total_tests output, 2
    assert_total_passes output, 1
    assert_total_failures output, 1
  end

  def test_errors_in_setup_are_handled
    create_file "test/test_spec.js", <<-test
      describe("tests", function() {
        beforeEach(function() {
          fooBar();
        });

        it("should be true", function() {
          expect(true).toBe(true);
        });
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
    assert_includes output, "ReferenceError: Can't find variable: fooBar"
  end

  def test_errors_in_teardown_are_handled
    create_file "test/test_spec.js", <<-test
      describe("tests", function() {
        afterEach(function() {
          fooBar();
        });

        it("should be true", function() {
          expect(true).toBe(true);
        });
      });
    test

    output, status = invoke

    refute status.success?, "Tests should fail"
    assert_includes output, "ReferenceError: Can't find variable: fooBar"
  end
end

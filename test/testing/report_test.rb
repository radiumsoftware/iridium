require 'test_helper'

class TestReportTest < MiniTest::Unit::TestCase
  def result(attributes = {})
    Iridium::TestResult.new({
      :backtrace => []
    }.merge(attributes))
  end

  def print(results)
    stdout, stderr = capture_io do
      Iridium::TestReport.new.print_results(results)
    end
    stdout
  end

  def test_report_contains_the_total_number_of_tests
    stdout = print [result, result]

    assert_includes stdout, "2 Test(s)"
  end

  def test_report_contains_the_number_of_assertions
    stdout = print [result(:assertions => 2), result(:assertions => 4)]

    assert_includes stdout, "6 Assertion(s)"
  end

  def test_report_contains_the_number_of_errors
    stdout = print [result(:error => true), result(:error => true)]

    assert_includes stdout, "2 Error(s)"
  end

  def test_report_contains_the_number_of_failures
    stdout = print [result(:failed => true), result(:failed => true)]

    assert_includes stdout, "2 Failure(s)"
  end

  def test_report_contains_failure_information
    failing_result = result({
      :failed => true,
      :name => "Test Label",
      :file => "/path/to/file.js",
      :message => "Assertion message",
    })

    stdout = print [failing_result]

    assert_includes stdout, failing_result.name
    assert_includes stdout, failing_result.file
    assert_includes stdout, failing_result.message
  end

  def test_report_contains_backtrace_for_errors
    error_result = result({
      :error => true,
      :name => "Test Label",
      :file => "/path/to/file.js",
      :message => "Assertion message",
      :backtrace => ['/backtrace/js:1']
    })

    stdout = print [error_result]

    assert_includes stdout, error_result.name
    assert_includes stdout, error_result.file
    assert_includes stdout, error_result.message
    assert_includes stdout, error_result.backtrace.first
  end
end

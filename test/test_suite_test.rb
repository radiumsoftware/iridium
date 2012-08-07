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

  def test_suite_collects_results_from_tests
    results = start mock_test, mock_test

    assert_equal 2, results.size
  end

  private
  def start(*test_files)
    options = test_files.extract_options!
    capture_io { Iridium::TestSuite.new(Iridium.application, test_files).run(options) }
  end
end

require 'test_helper'

class JSHintTest < MiniTest::Unit::TestCase
  def test_returns_no_results_on_a_good_file
    results = Iridium::JSLint.run Iridium::JSLint.source

    assert_kind_of Array, results
    assert_empty results
  end

  def test_parses_results
    results = Iridium::JSLint.run "foo = 'bar'"

    assert_kind_of Array, results
    assert_equal 2, results.size
    result = results.first
    assert_equal "'foo' was used before it was defined.", result.message
    assert_equal "foo = 'bar'", result.source
    assert_equal 1, result.line
  end
end

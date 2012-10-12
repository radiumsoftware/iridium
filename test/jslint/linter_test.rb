require 'test_helper'

class LinterTest < MiniTest::Unit::TestCase
  def linter
    Iridium::JSLint::Linter
  end

  def test_returns_no_results_on_a_good_file
    create_file "app/test.js", Iridium::JSLint::Linter.source

    results = linter.run Iridium.application.root.join("app", "test.js") 

    assert_kind_of Array, results
    assert_empty results
  end

  def test_parses_results
    create_file "app/test.js", "foo = 'bar'"

    results = linter.run Iridium.application.root.join("app", "test.js")

    assert_kind_of Array, results
    assert_equal 2, results.size
    result = results.first
    assert_equal "'foo' was used before it was defined.", result.message
    assert_equal "foo = 'bar'", result.source
    assert_equal 1, result.line
  end
end

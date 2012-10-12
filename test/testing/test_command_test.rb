require 'test_helper'

class TestCommandTest < MiniTest::Unit::TestCase
  def test_compile_accepts_an_optional_path_argument
    create_file "app/javascripts/app.js", "FOO"

    output_root = destination_root.join 'foo'

    FileUtils.mkdir_p output_root

    stdout, stderr = invoke ['compile', output_root.to_s]

    assert_empty stderr
    assert_file "foo/application.js"
  end

  def test_compile_blows_up_when_passed_an_invalid_path
    create_file "app/javascripts/app.js", "FOO"

    assert_raises RuntimeError do
      stdout, stderr = invoke ['compile', '/foo/bar/baz/qux']

      assert_includes stderr, "/foo/bar/baz/qux"
      assert_match stderr, /exist/
    end
  end
end

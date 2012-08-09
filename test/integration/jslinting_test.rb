require 'test_helper'

class JsLintingTest < MiniTest::Unit::TestCase
  def invoke(*args)
    stdout, stderr, status = nil

    stdout, stderr = capture_io do
      Dir.chdir Iridium.application.root do
        status = Iridium::Commands::JSLint.start(args)
      end
    end

    return status, stdout, stderr
  end

  def bad_file
    "foo = 'bar'"
  end

  def good_file
    Iridium::JSLint.source
  end

  def test_pukes_on_bad_files
    result, stdout, stderr = invoke "app/missing_file.js"

    assert_equal 2, result
    assert_includes stderr, "app/missing_file.js"
  end

  def test_returns_success_full_when_file_is_good
    create_file "app/javascripts/app.js", good_file

    result, stdout, stderr = invoke "app/javascripts/app.js"

    assert_equal 0, result
  end

  def test_returns_unsuccessfully_when_file_has_errors
    create_file "app/javascripts/app.js", bad_file

    result, stdout, stderr = invoke "app/javascripts/app.js"

    assert_equal 1, result
  end
end

require 'test_helper'

class CompileCommandTest < MiniTest::Unit::TestCase
  def setup ; end
  def teardown ; end

  def test_compile_command_calls_compile
    app = mock
    Iridium.application = app

    app.expects(:compile)

    Iridium::Pipeline::CompileCommand.new.invoke(:compile)
  end

  def test_path_can_be_passed_to_compile_into
    app = mock :compile => true
    Iridium.application = app

    app.expects(:site_path=).with(".")

    Iridium::Pipeline::CompileCommand.new.invoke(:compile, ["."])
  end

  def test_an_error_is_raised_when_path_is_invalid
    Iridium.application = mock

    assert_raises RuntimeError do
      Iridium::Pipeline::CompileCommand.new.invoke(:compile, ["/foo/bar"])
    end
  end
end

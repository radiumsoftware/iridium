require 'test_helper'

class HandlebarsPrecompilerTest < MiniTest::Unit::TestCase
  def test_compiles_a_template
    mock_app = stub
    mock_app.expects(:handlebars_path).returns(Handlebars::Source.bundled_path)

    template = <<-handlebars
    <div>{{name}} hello!</div>
    handlebars

    compiler = Iridium::Pipeline::HandlebarsPrecompiler.new mock_app

    result = compiler.compile template

    refute_empty result
    assert_match %r{function\s\(.+\)}m, result
  end
end

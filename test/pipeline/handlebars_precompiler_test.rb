require 'test_helper'

class HandlebarsPrecompilerTest < MiniTest::Unit::TestCase
  def test_compiles_a_template
    mock_app = stub
    mock_app.expects(:handlebars_path).returns(Iridium.vendor_path.join("handlebars.js"))

    template = <<-handlebars
    <div>{{name}} hello!</div>
    handlebars

    compiler = Iridium::HandlebarsPrecompiler.new mock_app

    result = compiler.compile template

    refute_empty result
    assert_match result, %r{function\s\(.+\)}m
  end
end

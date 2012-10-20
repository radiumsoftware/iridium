require 'test_helper'

class HandlebarsPrecompilerTest < MiniTest::Unit::TestCase
  def test_compiles_a_template
    template = <<-handlebars
    <div>{{name}} hello!</div>
    handlebars

    result = Iridium::HandlebarsPrecompiler.call template

    refute_empty result
    assert_match result, %r{Handlebars.template(.+);}m
  end
end

require 'test_helper'

class HandlebarsCompilerTest < MiniTest::Unit::TestCase
  def test_compiles_a_template
    template = <<-handlebars
    <div>{{name}} hello!</div>
    handlebars

    result = Iridium::HandlebarsCompiler.call template

    refute_empty result
  end
end

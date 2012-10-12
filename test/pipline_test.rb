require "test_helper"

class PipelineTest < MiniTest::Unit::TestCase
  def config
    Iridium.application.config
  end

  def test_load_add_dependences
    config.dependencies.load :foo

    assert_includes config.dependencies, :foo
  end

  def test_unload_removes_dependences
    config.dependencies << :foo
    config.dependencies.unload :foo

    assert_empty config.dependencies
  end

  def test_swap_dependencies
    config.dependencies.load :handlebars

    config.dependencies.swap :handlebars, :handlebars_runtime

    assert_includes config.dependencies, :handlebars_runtime
    refute_includes config.dependencies, :handlebars
  end
end

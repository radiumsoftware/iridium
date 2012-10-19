require "test_helper"

class PipelineTest < MiniTest::Unit::TestCase
  def config
    Iridium.application.config
  end

  def test_load_add_dependences
    config.dependencies.load :foo

    assert_includes config.dependencies.files, :foo
  end

  def test_unload_removes_dependences
    config.dependencies << :foo
    config.dependencies.unload :foo

    assert_empty config.dependencies.files
  end

  def test_swap_dependencies
    config.dependencies.load :handlebars

    config.dependencies.swap :handlebars, :handlebars_runtime

    assert_includes config.dependencies.files, :handlebars_runtime
    refute_includes config.dependencies.files, :handlebars
    assert_includes config.dependencies.skips, :handlebars
  end

  def test_files_contains_loaded_files_without_skips
    config.dependencies.load :a, :b, :c
    config.dependencies.skip :b

    assert_equal [:a, :c], config.dependencies.files
  end

  def test_components_can_add_js_processing_hooks
    component = Class.new Iridium::Component do
      javascript do |pipeline|
        # this code is not evaluated in this test
      end
    end

    assert_kind_of Hydrogen::CallbackSet, component.config.js_pipelines
    assert_equal 1, component.config.js_pipelines.size
  end

  def test_components_can_add_css_processing_hooks
    component = Class.new Iridium::Component do
      css do |pipeline|
        # this code is not evaluated in this test
      end
    end

    assert_kind_of Hydrogen::CallbackSet, component.config.css_pipelines
    assert_equal 1, component.config.css_pipelines.size
  end

  def test_components_can_add_optmization_processing_hooks
    component = Class.new Iridium::Component do
      optimize do |pipeline|
        # this code is not evaluated in this test
      end
    end

    assert_kind_of Hydrogen::CallbackSet, component.config.optimization_pipelines
    assert_equal 1, component.config.optimization_pipelines.size
  end
end

require "test_helper"

class PipelineTest < MiniTest::Unit::TestCase
  def config
    Iridium.application.config
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

  def test_components_can_add_hbs_processing_hooks
    component = Class.new Iridium::Component do
      hbs do |pipeline|
        # this code is not evaluated in this test
      end
    end

    assert_kind_of Hydrogen::CallbackSet, component.config.hbs_pipelines
    assert_equal 1, component.config.hbs_pipelines.size
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

  def test_components_can_add_finalization_processing_hooks
    component = Class.new Iridium::Component do
      finalize do |pipeline|
        # this code is not evaluated in this test
      end
    end

    assert_kind_of Hydrogen::CallbackSet, component.config.finalizers
    assert_equal 1, component.config.finalizers.size
  end
end

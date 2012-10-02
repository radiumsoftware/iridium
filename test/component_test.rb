require 'test_helper'
require 'iridium/component'

class ComponentTest < MiniTest::Unit::TestCase
  class MockMiddleware ; end

  def test_components_can_configure_the_middleware_stack
    Class.new Iridium::Component do
      middleware.use MockMiddleware
    end
  end

  def test_components_share_the_same_middleware_stack
    component1 = Class.new Iridium::Component
    component2 = Class.new Iridium::Component

    assert_equal component1.middleware, component2.middleware
  end

  def test_components_can_configure_vendor_paths
    asset_component = Class.new Iridium::Component do
      vendor_paths[:css].add "vendor/css"
    end
  end
end

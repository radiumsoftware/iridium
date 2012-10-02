require 'test_helper'

class Hydrogen::ComponentTest < MiniTest::Unit::TestCase
  def test_components_share_the_same_config
    carb = Class.new Hydrogen::Component do
      config.foo = :bar
    end

    manifold = Class.new Hydrogen::Component do
      config.bar = :baz
    end

    assert_equal :bar, manifold.config.foo
    assert_equal :baz, carb.config.bar
  end

  def test_inheriting_from_a_components_records_it
    header = Class.new Hydrogen::Component

    assert_includes Hydrogen::Component.subclasses, header
  end
end

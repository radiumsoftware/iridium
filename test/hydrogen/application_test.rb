require 'test_helper'

class Hydrogen::ApplicationTest < MiniTest::Unit::TestCase
  def test_applications_have_a_root
    app = Class.new Hydrogen::Application
    app.root = "/foo"
    assert_equal "/foo", app.root.to_s

    assert_equal app.root, app.new.root
  end

  def test_applications_have_a_config
    app = Class.new Hydrogen::Application
    assert app.config
  end

  def test_applications_can_be_configured_with_a_block
    app = Class.new Hydrogen::Application

    app.configure do 
      config.foo = :bar
    end

    assert_equal :bar, app.config.foo
  end
end

require 'test_helper'

class EngineTest < MiniTest::Unit::TestCase
  def test_app_paths
    component = Iridium::Engine.new

    assert_equal "app", component.paths[:app].first.path
    assert_equal "app/config/initializers", component.paths[:initializers].first.path
    assert_equal "app/locales", component.paths[:locales].first.path
    assert_equal "app/javascripts", component.paths[:javascripts].first.path
    assert_equal "app/templates", component.paths[:templates].first.path
    assert_equal "app/stylesheets", component.paths[:stylesheets].first.path
    assert_equal "app/assets", component.paths[:assets].first.path
    assert_equal "app/sprites", component.paths[:sprites].first.path
  end

  def test_vendor_path
    component = Iridium::Engine.new

    assert_equal "vendor", component.paths[:vendor].first.path
  end

  def test_build_paths
    component = Iridium::Engine.new

    assert_equal "site", component.paths[:site].first.path
    assert_equal "tmp", component.paths[:tmp].first.path
    assert_equal "tmp/build", component.paths[:build].first.path
  end
end

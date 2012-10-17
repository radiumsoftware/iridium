require 'test_helper'

class ApplicationTest < MiniTest::Unit::TestCase
  def app
    Iridium.application
  end

  def test_app_paths
    assert_equal "app", app.paths[:app].first.path
    assert_equal "app/config/initializers", app.paths[:initializers].first.path
    assert_equal "app/locales", app.paths[:locales].first.path
    assert_equal "app/javascripts", app.paths[:javascripts].first.path
    assert_equal "app/templates", app.paths[:templates].first.path
    assert_equal "app/stylesheets", app.paths[:stylesheets].first.path
  end

  def test_vendor_path
    assert_equal "vendor", app.paths[:vendor].first.path
  end

  def test_build_paths
    assert_equal "site", app.paths[:site].first.path
    assert_equal "tmp", app.paths[:tmp].first.path
    assert_equal "tmp/build", app.paths[:build].first.path
  end
end

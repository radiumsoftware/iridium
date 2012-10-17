require 'test_helper'

class ApplicationTest < MiniTest::Unit::TestCase
  def app
    Iridium.application
  end

  def test_application_paths_are_configured
    assert_equal "app", app.paths[:app].first.path

    assert_equal "vendor", app.paths[:vendor].first.path

    assert_equal "tmp", app.paths[:tmp].first.path
    assert_equal "tmp/build", app.paths[:build].first.path
  end
end

require 'test_helper'

class CompileCommandTest < MiniTest::Unit::TestCase
  def test_compile_generates_a_site
    create_file "app/javascripts/app.js", "FOO"

    invoke %w[compile]

    assert File.exists?(Iridium.application.site_path.join('application.js'))
  end
end

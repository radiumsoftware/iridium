require 'test_helper'

class RackupGeneratorTest < GeneratorTestCase
  def command
    Iridium::Generators::RackupGenerator
  end

  def test_generates_a_config_ru
    invoke ; assert_file "config.ru"

    assert_file "config.ru"

  end

  def test_rackup_file_runs_the_app
    invoke ; assert_file "config.ru"

    content = read "config.ru"

    assert_includes content, "run TestApp"
  end

  def test_rackup_file_requires_the_application
    invoke ; assert_file "config.ru"

    require_line = %Q{require File.expand_path("../application", __FILE__)}

    content = read "config.ru"

    assert_includes content, require_line
  end

  def test_generator_naming
    assert_equal "iridium", command.namespace
    assert_equal "rackup", command.generator_name
  end
end

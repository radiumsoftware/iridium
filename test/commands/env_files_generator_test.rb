require 'test_helper'

class EnvFilesGeneratorTest < GeneratorTestCase
  def command
    Iridium::Commands::Generate
  end

  def test_generator_creates_conf_directories
    invoke

    assert_file 'config', 'development.rb'
    assert_file 'config', 'test.rb'
    assert_file 'config', 'production.rb'

    assert_file 'config', 'settings.yml'
  end
end


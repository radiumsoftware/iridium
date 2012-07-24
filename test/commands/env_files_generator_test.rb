require 'test_helper'
require 'iridium/commands/env_files_generator'

class EnvFilesGeneratorTest < GeneratorTestCase
  def command
    Iridium::Commands::EnvFilesGenerator
  end

  def test_generator_creates_conf_directories
    invoke

    assert_file 'config', 'development.rb'
    assert_file 'config', 'test.rb'
    assert_file 'config', 'production.rb'

    assert_file 'config', 'settings.yml'
  end
end


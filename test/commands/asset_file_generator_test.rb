require 'test_helper'

class AssetFileGeneratorTest < GeneratorTestCase
  def command
    Iridium::Commands::Generate
  end

  def test_generator_creates_an_assetfile
    invoke

    assert_file 'Assetfile'
  end
end

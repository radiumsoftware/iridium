require 'test_helper'

class GenerateTest < GeneratorTestCase
  def command
    Iridium::Commands::Generate
  end

  def test_generator_creates_an_assetfile
    skip
    invoke "assetfile"

    assert_file 'Assetfile'

    content = read "Assetfile"

    stock_assetfile = File.expand_path "../../../lib/iridium/Assetfile", __FILE__

    assert_equal File.read(stock_assetfile), content
  end

  def test_generator_creates_confg_ru
    skip
    invoke "rackup"

    assert_file 'config.ru'

    content = read destination_root.join('config.ru')

    assert_includes content, 'run TestApp'
  end
end

require 'test_helper'

class RackupFileGeneratorTest < GeneratorTestCase
  def command
    Iridium::Commands::Generate
  end

  def test_generator_creates_confg_ru
    invoke

    assert_file 'config.ru'

    content = read destination_root.join('config.ru')

    assert_includes content, 'run TestApp'
  end
end

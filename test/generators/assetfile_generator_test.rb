require 'test_helper'

class AssetfileGeneratorTest < GeneratorTestCase
  def command
    Iridium::Generators::AssetfileGenerator
  end

  def test_copies_the_internal_assetfile
    invoke ; assert_file "Assetfile"

    expected = File.read(File.expand_path("../../../lib/iridium/pipeline/Assetfile", __FILE__))
    assert_equal expected, read("Assetfile")
  end

  def test_generator_naming
    assert_equal "iridium", command.namespace
    assert_equal "assetfile", command.generator_name
  end
end

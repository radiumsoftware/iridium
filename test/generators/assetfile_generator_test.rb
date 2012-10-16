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
end

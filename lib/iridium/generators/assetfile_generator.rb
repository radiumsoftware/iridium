module Iridium
  module Generators
    class AssetfileGenerator < Iridium::Generator
      self.source_root File.expand_path "../../pipeline", __FILE__

      desc "Generate an Assetfile"
      def assetfile
        copy_file "Assetfile"
      end
    end
  end
end

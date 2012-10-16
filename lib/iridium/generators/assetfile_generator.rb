module Iridium
  module Generators
    class AssetfileGenerator < Iridium::Generator
      desc "Generate an Assetfile"
      def assetfile
        copy_file "Assetfile"
      end
    end
  end
end

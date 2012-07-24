module Iridium
  module Commands
    class AssetFileGenerator < Generator
      include Thor::Actions

      def self.source_root
        File.expand_path '../../../../generators/application', __FILE__
      end

      desc "asset_file", "generates an Assetfile equivalent to the stock pipeline"
      def asset_file
        copy_file "Assetfile"
      end

      default_task :asset_file
    end
  end
end

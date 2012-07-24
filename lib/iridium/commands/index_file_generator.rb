module Iridium
  module Commands
    class IndexFileGenerator < Generator
      include Thor::Actions

      def self.source_root
        File.expand_path '../../../../generators/application', __FILE__
      end

      desc "index", "generates a file in public/index.html.erb used to boot your app"
      def index
        template "index.html.erb.tt", "app/public/index.html.erb"
      end

      default_task :index
    end
  end
end

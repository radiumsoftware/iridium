module Iridium
  module Commands
    class RackupFileGenerator < Generator
      include Thor::Actions

      def self.source_root
        File.expand_path '../../../../generators/application', __FILE__
      end

      desc "rackup", "generates a config.ru to serve your application in production"
      def rackup
        template "config.ru.tt"
      end

      default_task :rackup
    end
  end
end

module Iridium
  module Commands
    class EnvFilesGenerator < Generator
      def self.source_root
        File.expand_path '../../../../generators/application', __FILE__
      end

      desc "envs", "Generate configuration files for development, test, and production enviroments"
      def envs
        directory "config"
      end

      default_task :envs
    end
  end
end

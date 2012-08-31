module Iridium
  module Commands
    class Application < Thor
      include Thor::Actions

      default_task :application

      attr_reader :app_path

      def self.source_root
        File.expand_path '../../../../generators/application', __FILE__
      end

      desc "application PATH", "generates a new application"
      method_option :deployable, :type => :boolean
      method_option :assetfile, :type => :boolean
      method_option :index, :type => :boolean
      method_option :envs, :type => :boolean
      def application(app_path)
        @app_name = File.basename app_path

        self.destination_root = File.expand_path app_path, destination_root

        directory "app"
        directory "site"
        directory "test"
        directory "vendor"

        template "application.rb.tt"
        template "readme.md.tt"

        copy_file "gitignore", ".gitignore"

        directory "config"

        if options[:assetfile]
          copy_file "Assetfile"
        end

        if options[:deployable]
          template "config.ru.tt"
        end
      end

      no_tasks do
        def camelized
          @app_name.camelize
        end

        def underscored
          @app_name.underscore
        end
      end
    end
  end
end

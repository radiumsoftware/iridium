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
        @app_path = app_path

        self.destination_root = File.expand_path app_path, destination_root

        directory "app"
        directory "site"
        directory "test"
        template "application.rb.tt"

        copy_file "gitignore", ".gitignore"

        if options[:assetfile]
          copy_file "Assetfile"
        end

        if options[:deployable]
          template "config.ru.tt"
        end

        if options[:envs]
          directory "config"
        end

        if options[:index]
          template "index.html.erb.tt", "app/public/index.html.erb"
        end
      end

      no_tasks do
        def camelized
          app_path.camelize
        end

        def underscored
          app_path.underscore
        end
      end
    end
  end
end

module Iridium
  module Commands
    class  Application < Thor
      include Thor::Actions

      argument :app_path, :type => :string

      def self.source_root
        File.expand_path '../../../../generators/application', __FILE__
      end

      desc "application", "generates a new application"
      method_option :deployable, :type => :boolean, :default => true
      def application
        self.destination_root = File.expand_path app_path, destination_root

        underscored = app_path.underscore
        classified = underscored.classify

        directory "app"
        directory "config"
        directory "site"
        template "application.rb.tt"

        if options[:deployable]
          template "config.ru.tt"
        end
      end

      no_tasks do
        def classified
          app_path.classify
        end

        def underscored
          app_path.underscore
        end
      end

      default_task :application
    end
  end
end

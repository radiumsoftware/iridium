module Iridium
  class Generator < Thor
    include Thor::Actions

    no_tasks do
      def require_app
        begin
          require "#{Dir.pwd}/application"
        rescue LoadError
          $stderr.puts "Could not find application.rb. Are you in your app's root?"
          abort
        end
      end

      def app
        require_app unless Iridium.application

        Iridium.application
      end

      def app_name
        app.class.to_s
      end

      def underscored
        app_name.underscore
      end

      def camelized
        app_name
      end
    end
  end
end

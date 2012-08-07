module Iridium
  class Generator < Thor
    include Thor::Actions

    no_tasks do
      def app
        if !Iridium.application
          require "#{Dir.pwd}/application"
        end

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

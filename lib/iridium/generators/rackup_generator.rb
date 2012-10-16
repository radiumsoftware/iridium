module Iridium
  module Generators
    class RackupGenerator < Iridium::Generator
      desc "generate a config.ru"
      def rackup
        template "config.ru.tt"
      end

      no_tasks do
        def app
          Iridium.load!
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
end

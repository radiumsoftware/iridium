module Iridium
  class Generator < Hydrogen::Generator
    add_runtime_options!
    
    def self.base_root
      File.expand_path("../../../generators", __FILE__)
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

require 'iridium/generators/application_generator'
require 'iridium/generators/assetfile_generator'
require 'iridium/generators/rackup_generator'

# Allows iridium generators to be invoked without specifying
# the namespace. Example: "iridium generate app" instead of
# "iridium generate iridium:app"

Hydrogen::Generators.default_namespaces << :iridium

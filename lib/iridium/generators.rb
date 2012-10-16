module Iridium
  class Generator < Hydrogen::Generator
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

require 'iridium/generators/assetfile_generator'
require 'iridium/generators/rackup_generator'

module Iridium
  class Component < Hydrogen::Component
    class Configuration < Hydrogen::Component::Configuration
      def middleware
        @@options[:middleware] ||= MiddlewareStack.new
      end
    end

    class << self
      def middleware
        config.middleware
      end

      def vendor_paths
        instance.vendor_paths
      end
    end

    def config
      @config ||= Configuration.new
    end

    def vendor_paths
      @vendor_paths ||= Hydrogen::PathSet.new self.class.called_from
    end
  end
end

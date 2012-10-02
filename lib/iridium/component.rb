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
    end

    def config
      @config ||= Configuration.new
    end
  end
end

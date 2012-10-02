module Iridium
  module Rack
    module RackSupport
      extend ActiveSupport::Concern

      module ClassMethods
        def call(env)
          instance.call(env)
        end
      end

      def call(env)
        app.call env
      end

      def app
        server = self

        builder = Builder.new

        builder.use Middleware::RackLintCompatibility

        builder.use ::Rack::ConditionalGet
        builder.use Middleware::Caching, server
        builder.use Middleware::GzipRewriter, server

        config.middleware.each do |middleware|
          builder.use middleware.name, *middleware.args, &middleware.block
        end

        config.proxies.each_pair do |url, to|
          builder.proxy url, to
        end

        builder.run ::Rack::Directory.new server.site_path

        builder.to_app
      end
    end

    class Component < Iridium::Component
      config.middleware = MiddlewareStack.new
    end
  end
end

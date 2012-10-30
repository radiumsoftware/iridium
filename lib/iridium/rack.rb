require 'iridium/rack/builder'
require 'iridium/rack/dev_server'
require 'iridium/rack/reverse_proxy'

require 'iridium/rack/server_command'

require 'iridium/rack/middleware/add_cookie'
require 'iridium/rack/middleware/add_header'
require 'iridium/rack/middleware/caching'
require 'iridium/rack/middleware/gzip_rewriter'
require 'iridium/rack/middleware/rack_lint_compatibility'

require 'iridium/rack/middleware_stack'

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
        @app ||= begin
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

          builder.rewrite_urls

          builder.run ::Rack::Directory.new server.site_path

          builder.to_app
        end
      end
    end
  end

  class Component 
    include Rack::RackSupport

    command Rack::ServerCommand

    config.middleware = Rack::MiddlewareStack.new

    config.proxies = {}

    class << self
      def proxy(url, to)
        config.proxies[url] = to
      end
    end
  end
end

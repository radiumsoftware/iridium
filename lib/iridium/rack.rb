module Iridium
  module Rack
    extend ActiveSupport::Concern

    class Builder < ::Rack::Builder 
      def proxy(url, to)
        use ReverseProxy do
          reverse_proxy /^#{url}(\/.*)$/, "#{to}$1"
        end
      end
    end

    module ClassMethods
      def call(env)
        instance.app.call(env)
      end
    end

    def app
      server = self

      builder = Builder.new

      builder.use Middleware::RackLintCompatibility
      builder.use ::Rack::Deflater

      builder.use ::Rack::ConditionalGet
      builder.use Middleware::Caching, server.site_path, "max-age=0, private, must-revalidate"

      config.middleware.each do |middleware|
        builder.use middleware.name, *middleware.args, &middleware.block
      end

      config.proxies.each_pair do |url, to|
        builder.proxy url, to
      end

      builder.use ::Rack::Rewrite do
        rewrite '/', '/index.html'
        rewrite %r{^\/?[^\.]+\/?(\?.*)?$}, '/index.html$1'
      end

      builder.use Middleware::DefaultIndex, server
      builder.run ::Rack::Directory.new server.site_path

      builder.to_app
    end
  end
end

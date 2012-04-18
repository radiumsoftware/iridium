module FrontendServer
  module Rack
    def app
      server = self

      builder = ::Rack::Builder.new

      self.class.configurations.each do |configuration|
        configuration.call builder, config
      end

      builder.use ::Rack::Deflater

      builder.use ReverseProxy do
        reverse_proxy /^\/api(\/.*)$/, "#{server.config.server}$1"
      end

      builder.use ::Rack::Rewrite do
        rewrite '/', '/index.html'
        rewrite %r{^\/?[^\.]+\/?(\?.*)?$}, '/index.html$1'
      end

      if development?
        builder.use Rake::Pipeline::Middleware, pipeline
      end

      if production?
        builder.use ::Rack::ETag
        builder.use ::Rack::ConditionalGet
      end

      builder.run ::Rack::Directory.new 'site'

      builder.to_app
    end

    def call(env)
      app.call(env)
    end
  end
end

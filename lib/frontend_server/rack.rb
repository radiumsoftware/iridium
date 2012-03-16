module FrontendServer
  module Rack
    def app
      server = self

      builder = ::Rack::Builder.new

      builder.use ::Rack::Rewrite do
       rewrite '/', '/index.html'
      end

      self.class.configurations.each do |configuration|
        configuration.call builder, config
      end

      if development?
        builder.use Middleware::PipelineReloader, server
        builder.use Rake::Pipeline::Middleware, pipeline
      end

      builder.use ::Rack::ReverseProxy do
        reverse_proxy /^\/api(\/.*)$/, "#{server.config.server}$1"
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

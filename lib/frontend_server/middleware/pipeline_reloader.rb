module FrontendServer
  module Middleware
    class PipelineReloader
      IGNORED_REQUESTS = [/^\/api/, /favicon\.ico/, /^\/images/]

      def initialize(app, server)
        @app, @server = app, server
      end

      def call(env)
        @app.call env
      end

      def skip?(env)
        !IGNORED_REQUESTS.select {|r| env['PATH_INFO'] =~ r }.empty?
      end
    end
  end
end

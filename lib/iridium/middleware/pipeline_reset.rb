module Iridium
  module Middleware
    class PipelineReset
      def initialize(app, server)
        @app, @server = app, server
      end

      def call(env)
        @server.reset if reset? env

        @app.call env
      end

      private
      def reset?(env)
        env['PATH_INFO'] =~ /application\.(js|css)$/
      end
    end
  end
end

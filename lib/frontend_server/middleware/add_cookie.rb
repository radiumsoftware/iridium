module FrontendServer
  module Middleware
    class AddCookie 
      def initialize(app, name, value)
        @app, @name, @value = app, name, value
      end

      def call(env)
        status, headers, body = @app.call(env)

        Rack::Utils.set_cookie_header!(headers, @name, @value)

        [status, headers, body]
      end
    end
  end
end

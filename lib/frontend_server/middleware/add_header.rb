module FrontendServer
  module Middleware
    class AddHeader
      def initialize(app, header, value)
        @app, @header, @value = app, header, value
      end

      def call(env)
        env[header_name] = @value
        @app.call env
      end

      private
      def header_name
        rack_header = @header.gsub /^HTTP_/, ''
        rack_header.gsub('_', '-')
        "HTTP_#{rack_header}".upcase
      end
    end
  end
end

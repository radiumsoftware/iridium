module Iridium
  module Middleware
    class RackLintCompatibility
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        if remove_content_headers? status
          headers.delete 'content-type'
          headers.delete 'content-length'
        end

        [status, headers, body]
      end

      def remove_content_headers?(status)
        case status.to_i
        when 100..199
          true
        when 205, 206, 304
          true
        else
          false
        end
      end
    end
  end
end

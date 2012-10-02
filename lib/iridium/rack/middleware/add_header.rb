module Iridium
  module Rack
    module Middleware
      class AddHeader
        def initialize(app, header, value, options = {})
          @app, @header, @value, @options = app, header, value, options
        end

        def call(env)
          env[header_name] = @value if add? env
          @app.call env
        end

        private
        def add?(env)
          if @options[:url]
            env['PATH_INFO'].match @options[:url]
          else
            true
          end
        end

        def header_name
          rack_header = @header.gsub /^HTTP_/, ''
          rack_header.gsub!('-', '_')
          "HTTP_#{rack_header}".upcase
        end
      end
    end
  end
end

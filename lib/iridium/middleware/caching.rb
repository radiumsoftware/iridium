require 'digest/md5'

module Iridium
  module Middleware
    class Caching
      def initialize(app, iridium)
        @app, @iridium = app, iridium
      end

      def call(env)
        status, headers, body = @app.call(env)

        if asset?(env) || generated_index?(env)
          headers['Cache-Control'] = "max-age=0, private, must-revalidate"
        end

        [status, headers, body]
      end

      private
      def asset_path(env)
        root.join(env['PATH_INFO'].gsub(/^\//, '')).to_s
      end

      def asset?(env)
        File.exists?(asset_path(env))
      end

      def generated_index?(env)
        env['PATH_INFO'] =~ /^\/index\.html/ && !File.exists?(root.join("index.html"))
      end

      def root
        @iridium.site_path
      end
    end
  end
end

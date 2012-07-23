require 'digest/md5'

module Iridium
  module Middleware
    class Caching
      def initialize(app, root)
        @app, @root = app, root
      end

      def call(env)
        status, headers, body = @app.call(env)

        if asset? env
          headers['Cache-Control'] = "max-age=0, private, must-revalidate"
        end

        [status, headers, body]
      end

      private
      def asset_path(env)
        @root.join(env['PATH_INFO'].gsub(/^\//, '')).to_s
      end

      def asset?(env)
        File.exists?(asset_path(env))
      end
    end
  end
end

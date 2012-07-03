require 'digest/md5'

module Iridium
  module Middleware
    class StaticAssets
      def initialize(app, root, cache_control)
        @app, @root, @cache_control = app, root, cache_control
      end

      def call(env)
        status, headers, body = @app.call(env)

        if asset? env
          headers['Last-Modified'] = File.new(asset_path(env)).mtime.httpdate

          if body
            text = ""

            body.each do |part|
              text << part
            end

            headers['ETag'] = %Q("#{Digest::MD5.hexdigest(text)}")
          end

          headers['Cache-Control'] = @cache_control
        end

        [status, headers, body]
      end

      private
      def asset_path(env)
        @root.join('site', env['PATH_INFO'].gsub(/^\//, '')).to_s
      end

      def asset?(env)
        File.exists?(asset_path(env))
      end
    end
  end
end

require 'digest/md5'

module Iridium
  module Middleware
    class StaticAssets
      STATIC_EXTENSIONS = %w(js css jpeg jpg png html)

      def initialize(app, root, cache_control)
        @app, @root, @cache_control = app, root, cache_control
      end

      def call(env)
        status, headers, body = @app.call(env)

        if static_asset? env
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

      def static_asset?(env)
        STATIC_EXTENSIONS.select do |ext|
          env['PATH_INFO'] =~ %r{#{ext}$}
        end.first && File.exists?(asset_path(env))
      end
    end
  end
end

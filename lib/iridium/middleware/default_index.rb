require 'digest/md5'

module Iridium
  module Middleware
    class DefaultIndex
      def initialize(app, iridium)
        @app, @iridium = app, iridium
      end

      def call(env)
        if serve_index?(env)
          headers = {}
          headers['ETag'] = %Q{"#{etag}"}
          headers['Content-Type'] = 'text/html'

          [200, headers, [html]]
        else
          @app.call env
        end
      end

      private
      def iridium
        @iridium
      end

      def serve_index?(env)
        env['PATH_INFO'] =~ /^\/index\.html/ && !File.exists?(iridium.site_path.join("index.html"))
      end

      def html
        ERB.new(template).result(binding)
      end

      def etag
        Digest::MD5.hexdigest html
      end

      def template
        File.read(File.expand_path("../../templates/index.html.erb", __FILE__))
      end
    end
  end
end

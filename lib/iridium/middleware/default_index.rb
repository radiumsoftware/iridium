require 'digest/md5'

module Iridium
  module Middleware
    class DefaultIndex
      def initialize(app, iridium)
        @app, @iridium = app, iridium
      end

      def call(env)
        if serve_index?(env)
          [200, {'ETag' => %Q{"#{etag}"}}, html]
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
        <<-str
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title><%= iridium.class.to_s.classify %></title>

            <!--[if lt IE 9]>
              <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
            <![endif]-->

            <link href="/application.css" rel="stylesheet">
          </head>

          <body>
            <% iridium.config.dependencies do |script| %>
              <script src="<%= script.url %>"></script>
            <% end %>

            <script src="/application.js"></script>
            <script type="text/javascript">
              minispade.require("<%= iridium.class.to_s.underscore %>/app");
            </script>
          </body>
        </html>
        str
      end
    end
  end
end

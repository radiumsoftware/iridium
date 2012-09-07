require "rack/server"
require "rake-pipeline/middleware"

module Iridium
  class DevServer < Rack::Server
    class NotFound
      def call(env)
        [404, { "Content-Type" => "text/plain" }, ["not found"]]
      end
    end

    class DirectoryServer < Rack::Directory
      def initialize(app, root)
        super root, app
      end
    end

    def app
      Rack::Builder.new do
        use Middleware::RackLintCompatibility

        Iridium.application.config.middleware.each do |middleware|
          use middleware.name, *middleware.args, &middleware.block
        end

        Iridium.application.config.proxies.each_pair do |url, to|
          proxy url, to
        end

        use ::Rack::Rewrite do
          rewrite '/', '/index.html'
          rewrite %r{^\/?[^\.]+\/?(\?.*)?$}, '/index.html$1'
        end

        use Rake::Pipeline::Middleware, Iridium.application.assetfile
        use DirectoryServer, Iridium.application.site_path
        run NotFound.new
      end
    end
  end
end

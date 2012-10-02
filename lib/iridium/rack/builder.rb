module Iridium
  module Rack
    class Builder < ::Rack::Builder 
      def proxy(url, to)
        use ReverseProxy do
          reverse_proxy /^#{url}(\/.*)$/, "#{to}$1"
        end
      end

      def rewrite_urls 
        use ::Rack::Rewrite do
          rewrite '/', '/index.html'
          rewrite %r{^\/?[^\.]+\/?(\?.*)?$}, '/index.html$1'
        end
      end
    end
  end
end

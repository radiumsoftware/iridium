module Hydrogen
  class Component
    class << self
      def proxy(url, to)
        config.proxy(url, to)
      end
    end

    class Configuration
      def proxy(url, to)
        proxies[url] = to
      end
    end
  end
end

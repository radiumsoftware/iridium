module Iridium
  class Component
    class << self
      def proxy(url, to)
        config.proxies[to] = url
      end
    end
  end
end

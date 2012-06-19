module Iridium
  class MiddlewareStack
    attr_accessor :middleware, :proxies

    class Middleware < Struct.new(:name, :args, :block) ; end
    class Proxy < Struct.new(:url, :to) ; end

    delegate :each, :to => :middleware

    def initialize
      @middleware = []
      @proxies = []
    end

    def use(klass, *args, &block)
      middleware.push Middleware.new(klass, args, block)
    end

    def proxy(url, to)
      proxies.push Proxy.new(url, to)
    end
  end
end

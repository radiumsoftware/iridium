module Iridium
  class MiddlewareStack
    attr_accessor :middleware, :proxies

    class Middleware < Struct.new(:name, :args, :block) ; end

    delegate :each, :to => :middleware

    def initialize
      @middleware = []
      @proxies = []
    end

    def use(klass, *args, &block)
      middleware.push Middleware.new(klass, args, block)
    end
  end
end

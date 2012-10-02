module Iridium
  module Rack
    class MiddlewareStack
      attr_accessor :middleware, :proxies

      class Entry < Struct.new(:name, :args, :block) ; end

      delegate :each, :size, :to => :middleware

      def initialize
        @middleware = []
        @proxies = []
      end

      def use(klass, *args, &block)
        middleware.push Entry.new(klass, args, block)
      end

      def add_header(*args, &block)
        middleware.push Entry.new(Middleware::AddHeader, args, block)
      end

      def add_cookie(*args, &block)
        middleware.push Entry.new(Middleware::AddCookie, args, block)
      end
    end
  end
end

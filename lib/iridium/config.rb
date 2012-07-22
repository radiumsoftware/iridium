module Iridium
  class Config
    attr_accessor :settings
    attr_accessor :root
    attr_accessor :proxies

    def initialize
      @middleware_stack = MiddlewareStack.new
      @proxies = {}
    end

    def middleware
      @middleware_stack
    end

    def proxy(url, to)
      self.proxies[url] = to
    end

    def root=(value)
      if value.is_a? String
        @root = Pathname.new value
      else
        @root = value
      end
    end
  end
end

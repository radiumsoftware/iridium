module Iridium
  class Config
    attr_accessor :settings
    attr_accessor :cache_control
    attr_accessor :cache
    attr_accessor :root
    attr_accessor :perform_caching
    attr_accessor :proxies

    def initialize
      @middleware_stack = MiddlewareStack.new
      @proxies = {}

      @cache_control = "max-age=0, private, must-revalidate"

      @cache = {
        :metastore => Dalli::Client.new,
        :entitystore => "file:/tmp/entitystore",
        :allow_reload => false
      }
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

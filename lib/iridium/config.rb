module Iridium
  class Config
    class Dependency < Struct.new(:name, :options)
      def url
        if name.to_s =~ /https?:\/\//
          name
        else
          "/#{name}"
        end
      end
    end

    attr_accessor :settings
    attr_accessor :root
    attr_accessor :proxies
    attr_accessor :dependencies

    def initialize
      @middleware_stack = MiddlewareStack.new
      @proxies = {}
      @dependencies = []
    end

    def middleware
      @middleware_stack
    end

    def proxy(url, to)
      self.proxies[url] = to
    end

    def load(name, options = {})
      dependencies << Dependency.new(name, options)
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

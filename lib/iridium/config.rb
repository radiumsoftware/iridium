module Iridium
  class Config
    class DependencyArray < Array
      def load(*names)
        names.each do |name|
          self << name
        end
      end

      def unload(*names)
        names.each do |name|
          delete name
        end
      end

      def swap(existing, replacement)
        return unless include? existing

        self[index(existing)] = replacement
      end
    end

    attr_accessor :settings
    attr_accessor :root
    attr_reader :proxies
    attr_reader :dependencies
    attr_reader :scripts
    attr_reader :handlebars
    attr_reader :minispade
    attr_reader :pipeline

    def initialize
      @middleware_stack = MiddlewareStack.new
      @proxies = {}
      @dependencies = DependencyArray.new
      @scripts = DependencyArray.new
      @handlebars = ActiveSupport::OrderedOptions.new
      @minispade = ActiveSupport::OrderedOptions.new
      @pipeline = ActiveSupport::OrderedOptions.new
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

require 'active_support/ordered_options'

module Iridium
  class Config < ActiveSupport::OrderedOptions
    attr_accessor :settings
    attr_accessor :root
    attr_accessor :proxies
    attr_accessor :dependencies
    attr_accessor :scripts
    attr_reader :handlebars
    attr_reader :minispade

    def initialize
      @middleware_stack = MiddlewareStack.new
      @proxies = {}
      @dependencies = []
      @scripts = []
      @handlebars = ActiveSupport::OrderedOptions.new
      @minispade = ActiveSupport::OrderedOptions.new
    end

    def middleware
      @middleware_stack
    end

    def proxy(url, to)
      self.proxies[url] = to
    end

    def load(*names)
      names.each do |name|
        dependencies << name
      end
    end

    def script(*names)
      names.each do |name|
        scripts << name
      end
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

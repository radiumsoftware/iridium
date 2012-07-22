require "iridium/version"

require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'

require 'thor'

require 'dalli'

require 'yaml'
require 'erb'
require 'rack/rewrite'
require 'rack/cache'
require 'rake-pipeline'
require 'rake-pipeline/middleware'
require 'rake-pipeline-web-filters'

require 'iridium/reverse_proxy'

require 'iridium/middleware/rack_lint_compatibility'
require 'iridium/middleware/caching'
require 'iridium/middleware/add_header'
require 'iridium/middleware/add_cookie'

require 'iridium/config'
require 'iridium/middleware_stack'

require 'iridium/configuration'

require 'iridium/pipeline'
require 'iridium/rack'

module Iridium
  class << self
    def application
      @application
    end

    def application=(app)
      @application = app
    end
  end

  class Application
    include Configuration
    include Pipeline
    include Rack
    include Singleton

    class << self
      def inherited(base)
        raise "You cannot have more than one Iridium::Application" if Iridium.application
        super
        root_path = File.dirname caller.first.match(/(.+):\d+/)[1]
        base.root = root_path
        Iridium.application = base.instance
      end
    end

    def production?
      env == 'production'
    end

    def development?
      env == 'development'
    end

    def env
      ENV['RACK_ENV'] || 'development'
    end

    def initialize
      boot!
    end

    def boot!
      raise "root is not set. You must set the root directory before using!" unless root

      settings_file = root.join("config", "settings.yml").to_s

      if File.exists? settings_file
        config.settings = OpenStruct.new(YAML.load(ERB.new(File.read(settings_file)).result)[env])
      end

      begin
        require "#{root}/config/application.rb"
      rescue LoadError ; end

      begin
        require "#{root}/config/#{env}.rb"
      rescue LoadError
      end
    end
  end
end

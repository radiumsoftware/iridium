require 'iridium/version'

require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'

require 'active_support/ordered_options'

require 'thor'
require 'thin'
require 'json'
require 'yaml'
require 'erb'
require 'execjs'
require 'compass'

require 'rack/rewrite'
require 'rake-pipeline'
require 'rake-pipeline/middleware'
require 'rake-pipeline/drop_matcher'
require 'rake-pipeline/iridium_helper'

require 'rake-pipeline-web-filters'
require 'rake-pipeline-web-filters/iife_filter'
require 'rake-pipeline-web-filters/erb_filter'
require 'rake-pipeline-web-filters/i18n_filter'
require 'rake-pipeline-web-filters/manifest_filter'

require 'iridium/reverse_proxy'

require 'iridium/generator'

require 'iridium/dev_server'

require 'iridium/command_streamer'

require 'iridium/test_report'
require 'iridium/test_suite'
require 'iridium/test_result'
require 'iridium/test_runner'

require 'iridium/middleware/rack_lint_compatibility'
require 'iridium/middleware/caching'
require 'iridium/middleware/add_header'
require 'iridium/middleware/add_cookie'
require 'iridium/middleware/gzip_rewriter'

require 'iridium/config'
require 'iridium/middleware_stack'

require 'iridium/configuration'

require 'iridium/pipeline'
require 'iridium/rack'

require 'iridium/jslint'
require 'iridium/jslint_runner'
require 'iridium/jslint_report'

require 'iridium/commands/application'
require 'iridium/commands/test'
require 'iridium/commands/jslint'
require 'iridium/commands/generate'

require 'iridium/cli'

require 'iridium/handlebars_compiler'

require 'iridium/compass_configuration'

module Iridium
  class Error < StandardError ; end
  class MissingFile < Error ; end
  class MissingTestHelper < Error ; end
  class IncorrectLoadPath < Error ; end

  class << self
    def application
      @application
    end

    def application=(app)
      @application = app
    end

    def js_lib_path
      File.expand_path("../iridium/casperjs/lib", __FILE__)
    end

    def vendor_path
      Pathname.new(File.expand_path("../../vendor", __FILE__))
    end

    def load!
      return if Iridium.application

      begin
        require "#{Dir.pwd}/application"
      rescue LoadError
        $stderr.puts "Could not find application.rb. Are you in your app's root?"
        abort
      end
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
      ENV['IRIDIUM_ENV'] || ENV['RACK_ENV'] || 'development'
    end

    def initialize
      boot!
      super
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

require 'iridium/version'
require 'hydrogen'

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
require 'barber'

require 'rack/rewrite'
require 'rake-pipeline'
require 'rake-pipeline/middleware'
require 'rake-pipeline/iridium_helper'

require 'rake-pipeline-web-filters'
require 'rake-pipeline-web-filters/sass_filter_patch'
require 'rake-pipeline-web-filters/erb_filter'
require 'rake-pipeline-web-filters/i18n_filter'
require 'rake-pipeline-web-filters/manifest_filter'

# Declare the top level module with some utility 
# methods that other pieces of code need before filling
# in the rest

module Iridium
  class Error < StandardError ; end
  class MissingFile < Error ; end
  class MissingTestHelper < Error ; end
  class IncorrectLoadPath < Error ; end
  class AlreadyBooted < Error
    def to_s 
      "Cannot boot application twice!"
    end
  end

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

      env_file = "#{Dir.pwd}/config/environment.rb"

      if !File.exists? env_file
        $stderr.puts "Could not find environment.rb. Are you in your app's root?"
        abort
      else
        require env_file
      end
    end

    def env
      ENV['IRIDIUM_ENV'] || ENV['RACK_ENV'] || 'development'
    end
  end
end

require 'iridium/component'
require 'iridium/engine'
require 'iridium/pipeline'
require 'iridium/compass'
require 'iridium/rack'
require 'iridium/testing'
require 'iridium/jslint'
require 'iridium/application'

require 'iridium/generators'
require 'iridium/cli'

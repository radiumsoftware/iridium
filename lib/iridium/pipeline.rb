require 'fileutils'
require 'zlib'
require 'stringio'
require 'erb'

module Iridium
  module Pipeline
    extend ActiveSupport::Concern

    module ClassMethods
      def compile
        instance.compile
      end
    end

    attr_accessor :app_path, :site_path, :tmp_path, :vendor_path

    def initialize
      @app_path = root.join 'app'
      @site_path = root.join 'site'
      @tmp_path = root.join 'tmp'
      @vendor_path = root.join 'vendor'
    end

    def assetfile
      if File.exists? root.join('Assetfile')
        root.join('Assetfile').to_s
      else
        File.expand_path "../Assetfile", __FILE__
      end
    end

    def pipeline
      Rake::Pipeline::Project.new assetfile
    end

    def clean!
      FileUtils.rm_rf site_path
      FileUtils.rm_rf tmp_path
    end

    def compile
      clean!
      configure_compass

      Dir.chdir root do
        pipeline.invoke_clean
      end
    end

    def manifest_template
      File.read(File.expand_path("../templates/cache.manifest.erb", __FILE__))
    end

    def configure_compass
      Compass.reset_configuration!
      configuration = CompassConfiguration.new self
      Compass.add_configuration configuration
    end
  end
end

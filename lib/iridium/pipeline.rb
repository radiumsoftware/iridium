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

    attr_accessor :app_path, :site_path, :tmp_path

    def initialize
      @app_path = root.join 'app'
      @site_path = root.join 'site'
      @tmp_path = root.join 'tmp'
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

      Dir.chdir root do
        pipeline.invoke_clean
      end

      generate_cache_manifest if production?
    end

    def generate_cache_manifest
      assets = Dir[site_path.join '**', '*'].reject do |name|
        name =~ /\.gz$/ || File.directory?(name)
      end.collect { |f| f.gsub "#{site_path.to_s}/", '' }.join("\n")

      File.open site_path.join('cache.manifest'), "w+" do |manifest|
        manifest.puts ERB.new(manifest_template).result(binding).chomp
      end
    end

    def manifest_template
      File.read(File.expand_path("../templates/cache.manifest.erb", __FILE__))
    end
  end
end

require 'fileutils'

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

    def compile
      Dir.chdir root do
        pipeline.invoke_clean
      end
    end
  end
end

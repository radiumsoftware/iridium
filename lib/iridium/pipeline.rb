require 'iridium/pipeline/dependency_array'
require 'iridium/pipeline/handlebars_compiler'
require 'iridium/pipeline/compile_command'

module Iridium
  module Pipeline
    module PipelineSupport
      extend ActiveSupport::Concern

      module ClassMethods
        def compile
          instance.compile
        end
      end

      included do
        attr_accessor :app_path, :site_path, :tmp_path, :vendor_path
      end

      def initialize
        @app_path = root.join 'app'
        @site_path = root.join 'site'
        @tmp_path = root.join 'tmp'
        @vendor_path = root.join 'vendor'
      end

      def build_path
        tmp_path.join "builds"
      end

      def assetfile
        if File.exists? root.join('Assetfile')
          root.join('Assetfile').to_s
        else
          File.expand_path "../pipeline/Assetfile", __FILE__
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

        run_callbacks :before_compile

        Dir.chdir root do
          pipeline.invoke_clean
        end
      end
    end
  end

  class Component
    include Pipeline::PipelineSupport

    command Pipeline::CompileCommand

    config.pipeline = ActiveSupport::OrderedOptions.new

    config.pipeline.js_pipelines = []
    config.pipeline.css_pipelines = []
    config.pipeline.optimization_pipelines = []

    config.handlebars = ActiveSupport::OrderedOptions.new
    config.minispade = ActiveSupport::OrderedOptions.new

    config.dependencies = Pipeline::DependencyArray.new
    config.scripts = Pipeline::DependencyArray.new
  end
end

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

      def all_paths
        Hydrogen::PathSetProxy.new Engine.subclasses.map(&:paths)
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

        run_callbacks :before_compile, self

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

    config.js_pipelines = Hydrogen::CallbackSet.new
    config.css_pipelines = Hydrogen::CallbackSet.new
    config.optimization_pipelines = Hydrogen::CallbackSet.new

    config.handlebars = ActiveSupport::OrderedOptions.new
    config.minispade = ActiveSupport::OrderedOptions.new

    config.dependencies = Pipeline::DependencyArray.new
    config.scripts = Pipeline::DependencyArray.new

    class << self
      def before_compile(*args, &block)
        callback :before_compile, *args, &block
      end

      def javascript(*args, &block)
        config.js_pipelines.add *args, &block
      end
      alias js javascript

      def stylesheet(*args, &block)
        config.css_pipelines.add *args, &block
      end
      alias css stylesheet

      def optimize(*args, &block)
        config.optimization_pipelines.add *arg, &block
      end
      alias optimizations stylesheet
    end
  end
end

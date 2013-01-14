require 'iridium/pipeline/dependency_array'
require 'iridium/pipeline/handlebars_precompiler'
require 'iridium/pipeline/handlebars_precompilers'
require 'iridium/pipeline/compile_command'
require 'iridium/pipeline/inline_precompiler_filter'

module Iridium
  module Pipeline
    module PipelineSupport
      extend ActiveSupport::Concern

      module ClassMethods
        def compile
          instance.compile
        end
      end

      def assetfile
        if File.exists? root.join('Assetfile')
          root.join('Assetfile').to_s
        else
          File.expand_path "../pipeline/Assetfile", __FILE__
        end
      end

      def handlebars_path
        base = paths[:vendor].expanded.find do |path|
          File.exists? File.join(path, "javascripts", "handlebars.js")
        end

        return unless base

        File.join base, "javascripts", "handlebars.js"
      end

      def pipeline
        Rake::Pipeline::Project.new assetfile
      end

      def clean!
        FileUtils.rm_rf site_path
        FileUtils.rm_rf tmp_path
        FileUtils.rm_rf build_path
      end

      def before_compile!
        run_callbacks :before_compile, self
      end

      def compile
        clean!
        before_compile!

        Dir.chdir root do
          pipeline.invoke
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

    config.dependencies.load :minispade, :handlebars, :i18n, :jquery
    config.dependencies.skip "handlebars-runtime"

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
        config.optimization_pipelines.add *args, &block
      end
      alias optimizations optimize
    end

    js do |pipeline, app|
      if inline_precompiler = app.config.handlebars.inline_compiler
        pipeline.filter inline_precompiler
      end
    end
  end
end

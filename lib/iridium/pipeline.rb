require 'fileutils'

module AppPipelineHelper
  def app
    raise "Cannot use the Iridium specific pipeline without declaring an application!" unless Iridium.application
    Iridium.application
  end
end

module Rake
  class Pipeline
    module DSL
      class PipelineDSL
        include AppPipelineHelper
      end

      class ProjectDSL
        include AppPipelineHelper
      end
    end
  end
end

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

    def pipeline
      if File.exists? root.join('Assetfile')
        Rake::Pipeline::Project.new root.join('Assetfile').to_s
      else
        stock_pipeline
      end
    end

    def compile
      Dir.chdir root do
        pipeline.invoke_clean
      end
    end

    private
    def stock_pipeline
      Rake::Pipeline.build do
        input app.app_path
        output app.site_path

        # compile all erb templates. You can access "app" 
        # inside your templates like this: <% app.config %>
        match "**/*.erb" do
          erb :binding => binding
        end

        match "**/*.handlebars" do
          handlebars
        end

        match "**/*.coffee" do
          coffee_script
        end

        match "**/*.less" do
          less
        end

        # Compile all Javascript files into Minispade modules.
        # Files in app/vendor/javascripts become modules
        # based on their file name. Files in app/javascripts
        # becomes modules inside your application namespace.
        #
        # Examples:
        # app/vendor/javascripts/jquery.min.js -> minispade.require('jquery');
        # app/javascripts/boot.js -> minispade.require('app_name/boot');
        # app/javascripts/views/main.js -> minispade.require('app_name/views/main');
        match "{javascripts,vendor/javascripts}/**/*.js" do
          minispade :module_id_generator => proc { |input|
            if input.path =~ /vendor/
              File.basename(input.path, '.js').gsub('.min', '')
            else
              input.path.gsub(/javascripts\//, "#{app.class.to_s.demodulize.underscore}/").gsub(/\.js$/, '')
            end
          }

          # minifiy Javascript when compiling assets for production
          uglify if app.production?

          # Finally concatenate all javascript files into a single
          # application.js
          concat "application.js"
        end

        # compile all SCSS files into equivalent css file.
        # SCSS partials are not included in compiled output.
        match /stylesheets\/(?:.+\/)?[^_].+\.scss/ do
          sass
        end

        # select all stylesheets in the project
        match "{vendor/stylesheets,stylesheets}/**/*.css" do
          # minifiy CSS when compiling assets for production
          yui_css if app.production?

          # finally concatenate all stylesheets into a single
          # application.css file.
          concat_css "application.css"
        end

        # All files in app/public are simpliy copied into the output directory.
        # Example:
        # app/public/index.html -> site/index.html
        match "public/**/*" do
          copy do |input|
            input.sub(/public\//, '')
          end
        end

        # All files needed per env copied into public
        # Example:
        # app/dependencies/faye.min.js -> side/faye.min.js
        match "dependencies/**/*" do
          copy do |input|
            input.sub(/dependencies\//, '')
          end
        end

        # All images are moved int
        match "images/**/*" do
          copy
        end
      end
    end
  end
end

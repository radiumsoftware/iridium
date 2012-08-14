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
        match "javascripts/**/*.js" do
          minispade :rewrite_requires => true, :module_id_generator => proc { |input|
            input.path.gsub(/javascripts\//, "#{app.class.to_s.demodulize.underscore}/").gsub(/\.js$/, '')
          }

          concat "build/lib.js"
        end

        # Use the specified vendor order to create a vendor.js file
        match "vendor/javascripts/*.js" do
          ordered_files = app.config.dependencies.collect { |f| "vendor/javascripts/#{f}.js" }
          filter Rake::Pipeline::OrderingConcatFilter, ordered_files, "build/vendor.js"
        end

        # minify and contact lib.js and vendor.js into a single
        # application.js
        match "build/*.js" do
          minify if app.production?

          filter Rake::Pipeline::OrderingConcatFilter, ["build/vendor.js", "build/lib.js"], "application.js"
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

        # All images are moved int
        match "images/**/*" do
          copy
        end
      end
    end
  end
end

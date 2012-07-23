require 'fileutils'

module Iridium
  module Pipeline
    extend ActiveSupport::Concern

    class OrderedCssConcatFilter < Rake::Pipeline::ConcatFilter
      def generate_output(inputs, output)
        sorted = inputs.sort do |file1, file2| 
          if (file1.path =~ /vendor/ && file2.path =~ /vendor/) || (file1.path !~ /vendor/ && file2.path !~ /vendor/)
            File.basename(file1.path, ".css") <=> File.basename(file2.path, ".css")
          elsif file2.path =~ /vendor/ && file1.path !~ /vendor/
            1
          else
            -1
          end
        end

        sorted.each do |input|
          output.write input.read
        end
      end
    end

    module ClassMethods
      def compile
        instance.compile
      end
    end

    def app_path
      root.join 'app'
    end

    def site_path
      root.join 'site'
    end

    def tmp_path
      root.join 'tmp'
    end

    def reset
      FileUtils.rm_rf site_path
      FileUtils.rm_rf tmp_path
    end

    def compile
      reset
      project.invoke
    end

    def pipeline
      app = self
      sass_options = {}
      sass_options[:images_idr] = '/images'
      sass_options[:http_images_path] = '/images'

      if development?
        sass_options[:line_comments] = true
        sass_options[:output_style] = :expanded
      else
        sass_options[:line_comments] = false
        sass_options[:output_style] = :compressed
      end

      _pipeline = Rake::Pipeline.build do
        input app.app_path
        output app.site_path

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

        match "{javascripts,vendor/javascripts}/**/*.js" do
          minispade :module_id_generator => proc { |input|
            if input.path =~ /vendor/
              File.basename input.path, '.js'
            else
              input.path.gsub(/javascripts\//, "#{app.module_name}/").gsub(/\.js$/, '')
            end
          }

          uglify if app.production?

          concat "application.js"
        end

        match /stylesheets\/(?:.+\/)?[^_].+\.scss/ do
          sass sass_options
        end

        match "{vendor/stylesheets,stylesheets}/**/*.css" do
          yui_css if app.production?

          filter OrderedCssConcatFilter, "application.css"
        end

        match "public/**/*" do
          copy do |input|
            input.sub(/public\//, '')
          end
        end

        match "external/**/*" do
          copy do |input|
            input.sub(/external\//, '')
          end
        end

        match "images/**/*" do
          copy
        end
      end

      _pipeline.tmpdir = tmp_path

      _pipeline
    end

    def project
      Rake::Pipeline::Project.new pipeline
    end

    def module_name
      self.class.to_s.demodulize.underscore
    end
  end
end

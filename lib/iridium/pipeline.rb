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
      def call(env)
        new.call(env)
      end

      def compile_assets
        new.compile_assets
      end
    end

    def app_path
      "#{root}/app"
    end

    def site_path
      "#{root}/site"
    end

    def tmp_path
      "#{root}/tmp"
    end

    def reset
      FileUtils.rm_rf site_path
      FileUtils.rm_rf tmp_path
    end

    def compile_assets
      reset
      project.invoke
    end

    def pipeline
      server = self
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
        input server.app_path
        output server.site_path

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
              input.path.gsub(/javascripts\//, "#{server.module_name}/").gsub(/\.js$/, '')
            end
          }

          uglify if server.production?

          concat "application.js"
        end

        match "stylesheets/**/*.scss" do
          sass sass_options
        end

        match "{vendor/stylesheets,stylesheets}/**/*.css" do
          yui_css if server.production?

          filter OrderedCssConcatFilter, "application.css"
        end

        match "public/**/*" do
          copy do |input|
            input.sub(/public\//, '')
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

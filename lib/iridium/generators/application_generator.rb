module Iridium
  module Generators
    class ApplicationGenerator < Iridium::Generator
      desc "generate a new application in PATH"

      self.source_paths << Iridium.vendor_path

      class_option :deployable, :type => :boolean
      class_option :assetfile, :type => :boolean
      class_option :index, :type => :boolean
      class_option :envs, :type => :boolean

      argument :app_path, :type => :string

      def self.vendored_scripts
        %w(minispade jquery handlebars i18n)
      end

      def application
        @app_name = File.basename app_path

        self.destination_root = File.expand_path app_path, destination_root

        directory "app"
        directory "site"
        directory "test"
        directory "vendor"

        self.class.vendored_scripts.each do |script|
          copy_file "#{script}.js", "vendor/javascripts/#{script}.js"
        end

        template "application.rb.tt"
        template "readme.md.tt"

        copy_file "gitignore", ".gitignore"

        directory "config"
      end

      no_tasks do
        def camelized
          @app_name.camelize
        end

        def underscored
          @app_name.underscore
        end
      end
    end
  end
end

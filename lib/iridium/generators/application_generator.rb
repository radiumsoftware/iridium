module Iridium
  module Generators
    class ApplicationGenerator < Iridium::Generator
      def self.generator_name
        "app"
      end

      desc "generate a new application in PATH"

      self.source_paths << Iridium.vendor_path

      class_option :deployable, :type => :boolean
      class_option :assetfile, :type => :boolean
      class_option :index, :type => :boolean
      class_option :envs, :type => :boolean
      class_option :test_framework, :type => :string, :default => 'qunit'

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

        case options[:test_framework]
        when 'qunit'
          template "test_frameworks/qunit/qunit.js", "test/framework/qunit.js"
          template "test_frameworks/qunit/qunit.css", "test/framework/qunit.css"
          template "test_frameworks/qunit/loader.html.erb.tt", "test/framework/loader.html.erb"
          template "test_frameworks/qunit/navigation_test.coffee.tt", "test/integration/navigation_test.coffee"

          template "test_frameworks/qunit/truth_test.coffee.tt", "test/unit/truth_test.coffee"
        when 'jasmine'
          template "test_frameworks/jasmine/jasmine.js", "test/framework/jasmine.js"
          template "test_frameworks/jasmine/jasmine.css", "test/framework/jasmine.css"
          template "test_frameworks/jasmine/loader.html.erb.tt", "test/framework/loader.html.erb"

          template "test_frameworks/jasmine/jasmine-html.js", "test/support/jasmine-html.js"

          template "test_frameworks/jasmine/navigation_spec.coffee.tt", "test/integration/navigation_spec.coffee"
          template "test_frameworks/jasmine/truth_spec.coffee.tt", "test/unit/truth_spec.coffee"
        end

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

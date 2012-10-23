module Iridium
  module Generators
    class PluginGenerator < Iridium::Generator
      desc "generate a new plugin named NAME"

      argument :plugin_name, :type => :string

      def plugin
        self.destination_root = File.expand_path plugin_name, destination_root

        directory "app"
        directory "vendor"
        directory "lib"

        copy_file "Gemfile"

        copy_file "LICENSE"

        template "readme.md"

        template "gemspec", "#{underscored}.gemspec"

        inside do
          run "git init", :capture => true
          say "Initialized Git repo"
        end
      end

      no_tasks do
        def camelized
          @plugin_name.camelize
        end

        def underscored
          @plugin_name.underscore
        end
      end
    end
  end
end

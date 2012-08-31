require 'iridium/commands/application'
require 'iridium/commands/test'
require 'thor/group'

module Iridium
  class CLI < Thor
    class << self
      def subcommand_with_default(subcommand, subcommand_class)
        self.subcommands << subcommand.to_s
        subcommand_class.subcommand_help subcommand

        define_method(subcommand) do |*args|
          args, opts = Thor::Arguments.split(args)
          invoke subcommand_class, [subcommand_class.default_task, args].flatten, opts
        end
      end
    end

    desc "app PATH", "generate a new application in PATH"
    subcommand_with_default "app", Commands::Application

    desc "generate NAME", "runs the NAME generator"
    subcommand "generate", Commands::Generate

    desc "server", "start a development server"
    def server
      ENV['IRIDIUM_ENV'] = 'development'
      Iridium.load!
      Iridium.application.clean!
      Iridium::DevServer.new.start
    end

    desc "compile PATH", "compile assets for deployment to an optional PATH"
    method_option :environment, :aliases => '-e', :default => 'production'
    def compile(path = nil)
      ENV['IRIDIUM_ENV'] = options[:environment]

      Iridium.load!

      if path
        raise "#{path} does not exist!" unless File.directory? path
        Iridium.application.site_path = Pathname.new path
      end

      Iridium.application.compile
    end
  end
end

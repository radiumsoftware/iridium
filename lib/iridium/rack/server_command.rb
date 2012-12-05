module Iridium
  module Rack
    class ServerCommand < Hydrogen::Command
      description "Start a preview server"

      desc "server", "start a development server"
      method_option :environment, :aliases => '-e', :default => 'development'
      def server
        ENV['IRIDIUM_ENV'] = options[:environment]

        Iridium.load!
        Iridium.application.clean!
        Iridium::Rack::DevServer.new.start
      end

      default_task :server
    end
  end
end

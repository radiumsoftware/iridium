module Iridium
  module Rack
    class ServerCommand < Hydrogen::Command
      description "Start a preview server"

      desc "server", "start a development server"
      method_option :environment, :aliases => '-e', :default => 'development'
      method_option :port, :aliases => '-p', :default => '8080'
      def server
        ENV['IRIDIUM_ENV'] = options[:environment]

        Iridium.load!
        Iridium.application.clean!
        Iridium::Rack::DevServer.new(Port: options[:port]).start
      end

      default_task :server
    end
  end
end

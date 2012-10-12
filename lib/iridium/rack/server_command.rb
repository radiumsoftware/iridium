module Iridium
  module Rack
    class ServerCommand < Hydrogen::Command
      description "Start a preview server"

      desc "server", "start a development server"
      def server
        ENV['IRIDIUM_ENV'] = 'development'
        Iridium.load!
        Iridium.application.clean!
        Iridium::DevServer.new.start
      end

      default_task :server
    end
  end
end

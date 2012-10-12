module Iridium
  module Pipeline
    class ServerCommand < Hydrogen::Command
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

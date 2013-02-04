module Iridium
  module Testing
    class TestCommand < Hydrogen::Command
      description "Executes tests"

      desc "test", "Execute compile tests in phantomjs"

      method_option :debug, :type => :boolean, :default => false,
        :desc => "Pring console.log messages"
      method_option :timeout, :type => :numeric, :default => 60000,
        :desc => "Time out length in ms"

      def test
        ENV['IRIDIUM_ENV'] = 'test'

        Iridium.load!
        Iridium.application.boot!
        Iridium.application.compile

        parts = []

        parts << 'phantomjs'
        parts << %Q{"#{Iridium.phantom_js_test_runner}"}
        parts << %Q{"#{Iridium.application.site_path}/tests.html"}
        parts << options[:timeout]

        if options[:debug]
          parts << "--debug"
        end

        command = parts.join " "

        exec command
      end

      default_task :test
    end
  end
end

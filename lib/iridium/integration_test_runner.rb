require 'active_support/core_ext/class'
require 'rack/server'
require 'pty'

module Iridium
  class IntegrationTestRunner
    class TestServer < ::Rack::Server
      def app
        Iridium.application
      end
    end

    attr_reader :files, :collector

    def initialize(files, collector = [])
      @files, @collector = files, collector
    end

    def run(options = {})
      server_thread = Thread.new do
        puts "Starting test Server..."
        TestServer.new(:Port => 7777).start
      end

      file_arg = files.map { |f| %Q{"#{f}"} }.join " "

      js_test_runner = File.expand_path('../casperjs/test_runner.js', __FILE__)

      js_command = %Q{casperjs "#{js_test_runner}" #{file_arg}}

      begin
        PTY.spawn js_command do |stdin, stdout, pid|
          begin
            stdin.each do |output|
              if output =~ %r{<iridium>(.+)</iridium>}
                collector << TestResult.new(JSON.parse($1))
              elsif options[:debug]
                puts output
              end
            end
          rescue Errno::EIO
          end
        end
      rescue PTY::ChildExited
      end

      server_thread.kill

      collector
    end
  end
end

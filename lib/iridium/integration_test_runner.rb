require 'active_support/core_ext/class'
require 'rack/server'

module Iridium
  class IntegrationTestRunner
    class TestServer < ::Rack::Server
      def app
        Iridium.application
      end
    end

    attr_reader :files

    def initialize(files)
      @files = files
    end

    def run(options = {})
      server_thread = Thread.new do
        puts "Starting test Server..."
        TestServer.new(:Port => 7777).start
      end

      file_arg = files.map { |f| %Q{"#{f}"} }.join " "

      js_test_runner = File.expand_path('../casperjs/test_runner.js', __FILE__)

      output = `casperjs "#{js_test_runner}" #{file_arg}`

      json = output.match(%r{<iridium>(.+)</iridium>})[1]

      server_thread.kill

      JSON.parse(json).map { |hash| TestResult.new(hash) }
    end
  end
end

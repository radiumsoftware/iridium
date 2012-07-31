require 'active_support/core_ext/class'
module Iridium
  class IntegrationTestRunner
    attr_reader :files, :collector

    def self.runner_path
      File.expand_path('../casperjs/integration_test_runner.js', __FILE__)
    end

    def initialize(files, collector = [])
      @files, @collector = files, collector
    end

    def run(options = {})
      file_arg = files.map { |f| %Q{"#{f}"} }.join " "

      return collector if options[:dry_run]

      command = %Q{casperjs "#{self.class.runner_path}" #{file_arg}}

      begin
        streamer = CommandStreamer.new command
        streamer.run options do |message|
          collector << TestResult.new(message)
        end
      rescue CommandStreamer::CommandFailed => ex
        result = TestResult.new :error => true
        result.name = "Javascript Execution Error"
        result.backtrace = ex.backtrace

        collector << result
      end

      collector
    end
  end
end

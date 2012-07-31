require 'active_support/core_ext/class'
module Iridium
  class IntegrationTestRunner
    attr_reader :files, :collector

    def initialize(files, collector = [])
      @files, @collector = files, collector
    end

    def run(options = {})
      file_arg = files.map { |f| %Q{"#{f}"} }.join " "

      js_test_runner = File.expand_path('../casperjs/test_runner.js', __FILE__)

      return collector if options[:dry_run]

      command = %Q{casperjs "#{js_test_runner}" #{file_arg}}

      streamer = CommandStreamer.new command
      streamer.run options do |message|
        collector << TestResult.new(message)
      end

      collector
    end
  end
end

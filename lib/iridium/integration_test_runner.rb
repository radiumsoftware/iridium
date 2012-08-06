module Iridium
  class IntegrationTestRunner
    attr_reader :app, :files, :collector

    def initialize(app, files, collector = [])
      @app, @files, @collector = app, files, collector
    end

    def run(options = {})
      file_arg = files.map { |f| %Q{"#{f}"} }.join " "

      return collector if options[:dry_run]

      js_test_runner = File.expand_path('../casperjs/integration_test_runner.coffee', __FILE__)

      command_options = { 
        "lib-path" => Iridium.js_lib_path,
        "test-path" => app.root.join('test')
      }

      switches = command_options.keys.map { |s| %Q{--#{s}="#{command_options[s]}"} }.join(" ")
      file_args = files.map { |f| %Q{"#{f}"} }.join(" ")

      command = %Q{casperjs "#{js_test_runner}" #{file_args} #{switches}}

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

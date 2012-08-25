module Iridium
  class TestRunner
    attr_reader :app, :files, :collector

    def initialize(app, files, collector = [])
      @app, @files, @collector = app, files, collector
    end

    def run(options = {})
      file_arg = files.map { |f| %Q{"#{f}"} }.join " "

      return collector if options[:dry_run]

      js_test_runner = File.expand_path('../casperjs/test_runner.coffee', __FILE__)

      command_options = { 
        "lib-path" => Iridium.js_lib_path,
        "index" => app.site_path.join('unit_test_runner.html'),
        "support-files" => Dir[app.root.join('test', 'support', '**', "*.{js,coffee}")].map { |f| %Q{"#{f}"} }.join(',')
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

module Iridium
  module Testing
    class Runner
      attr_reader :app, :files, :collector, :logger

      def initialize(app, files, logger, collector = [])
        @app, @files, @logger, @collector = app, files, logger, collector
      end

      def run(options = {})
        file_arg = files.map { |f| %Q{"#{f}"} }.join " "

        return collector if options[:dry_run]

        js_test_runner = File.expand_path('../../casperjs/test_runner.coffee', __FILE__)

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
            case message['signal']
            when 'test'
              collector << Result.new(message['data'])
            when 'log'
              case message['level']
              when 'warning'
                logger.warn message['data']
              else
                logger.send message['level'], message['data']
              end
            end
          end
        rescue CommandStreamer::CommandFailed => ex
          result = Result.new :error => true
          result.name = "Javascript Execution Error"
          result.backtrace = ex.backtrace

          collector << result
        end

        collector
      end
    end
  end
end

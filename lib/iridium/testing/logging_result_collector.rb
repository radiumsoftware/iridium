module Iridium
  module Testing
    class LoggingResultCollector
      def initialize(report, log_level = 'warn')
        @result_collector = report.collector

        @logger = Logger.new $stdout
        @logger.level = case log_level
                       when 'debug'
                         Logger::DEBUG
                       when 'info'
                         Logger::INFO
                       when 'warn'
                         Logger::WARN
                       when 'error'
                         Logger::ERROR
                       else
                         Logger::WARN
                       end
      end

      def <<(message)
        if message.test_result?
          @result_collector << message.test_result
        elsif message.log?
          @logger.send message.level, message.message
        end
      end

      def to_a
        @result_collector.to_a
      end

      def clear
        @result_collector.clear
      end
    end
  end
end

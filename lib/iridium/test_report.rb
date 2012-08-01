module Iridium
  class TestReport
    class Collector < Array
      def initialize(report)
        super 0
        @report = report
      end

      def <<(result)
        @report.print_result result
        super result
      end
    end

    attr_reader :io

    def initialize(io = $stdout)
      @io = io
    end

    def collector
      @collector ||= Collector.new self
    end

    def print_result(result)
      if result.passed?
        io.print "."
      elsif result.error?
        io.print "E"
      elsif result.failed?
        io.print "F"
      end
    end

    def print_results(results)

    end
  end
end

module Iridium
  class JSLintReport
    def initialize(io = $stdout)
      @io = io
    end

    def print(result)
      if result.empty?
        @io.print "."
      else
        @io.print "F"
      end
    end

    def print_results(results)

    end
  end
end

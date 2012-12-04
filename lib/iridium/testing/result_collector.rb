module Iridium
  module Testing
    class ResultCollector
      def initialize
        @array = []
      end

      def <<(message)
        @array << message
      end

      def clear
        @array.clear
      end

      def to_a
        @array.select(&:test_result?).map(&:test_result)
      end
    end
  end
end

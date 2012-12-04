module Iridium
  module Testing
    class Message
      def initialize(hash)
        @hash = hash
      end

      def test_result?
        @hash['signal'] == 'test'
      end

      def test_result
        return unless test_result?

        Result.new @hash['data']
      end

      def log?
        @hash['signal'] == 'log'
      end

      def level
        return unless log?

        case @hash['level']
        when 'warning'
          'warn'
        else
          @hash['level']
        end
      end

      def message
        return unless log?

        @hash['data']
      end

      def file
        return unless log?

        @hash['file']
      end
    end
  end
end

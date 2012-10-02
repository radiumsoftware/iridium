module Hydrogen
  class Application < Component
    class << self
      def configure(&block)
        class_eval &block
      end

      def root
        @root
      end

      def root=(value)
        if value.is_a? String
          @root = Pathname.new value
        else
          @root = value
        end
      end
    end

    def root
      self.class.root
    end
  end
end

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

      def inherited(base)
        Component.loaded.each do |component|
          component.app.extensions.each do |extension|
            base.send :extend, extension
          end

          component.app.includes.each do |inclusion|
            base.send :include, inclusion
          end
        end

        super
      end
    end

    def root
      self.class.root
    end
  end
end

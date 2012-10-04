module Hydrogen
  class Component
    class << self
      def before_compile(&block)
        callback :before_compile, &block
      end
    end
  end
end

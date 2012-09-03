module Iridium
  module Configuration
    extend ActiveSupport::Concern

    delegate :root, :config, :to => :klass

    def klass
      self.class
    end

    module ClassMethods
      def config
        @config ||= Config.new
      end

      def root
        config.root
      end

      def root=(root)
        config.root = root
      end

      def configure(&block)
        class_eval &block
      end

      def settings
        config.settings
      end
    end
  end
end

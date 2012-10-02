module Hydrogen
  class Component
    class Configuration
      def initialize
        @@options ||= {}
      end

      def respond_to?(name)
        super || @@options.key?(name.to_sym)
      end

      private
      def method_missing(name, *args, &blk)
        if name.to_s =~ /=$/
          @@options[$`.to_sym] = args.first
        elsif @@options.key?(name)
          @@options[name]
        else
          super
        end
      end
    end

    class << self
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        subclasses << base
        base.extend Hydrogen::Configurable
      end
    end

    def config
      @config ||= Configuration.new
    end
  end
end

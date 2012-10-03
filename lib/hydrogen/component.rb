module Hydrogen
  class Component
    class Configuration
      def initialize
        @@options ||= {}
        @@options[:commands] ||= []
        @@options[:callbacks] ||= {}
      end

      def commands
        @@options[:commands]
      end

      def respond_to?(name)
        super || @@options.key?(name.to_sym)
      end

      private
      def options
        @@options
      end

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

    class AppProxy
      def initialize
        @extensions, @includes = [], []
      end

      def extend(klass)
        @extensions << klass
      end

      def include(klass)
        @includes << klass
      end

      def extensions
        @extensions
      end

      def includes
        @includes
      end
    end

    class << self
      def abstract!
        @abstract = true
      end

      def abstract?
        @abstract
      end

      def loaded
        @loaded ||= []
      end

      def called_from
        @called_from
      end

      def called_from=(path)
        @called_from = path
      end

      def inherited(base)
        return if abstract?

        loaded << base
        base.called_from = File.dirname(caller.first.sub(%r{:\d+.*}, ''))
      end

      def config
        instance.config
      end

      def instance
        @instance ||= new
      end

      def command(klass, name)
        commands << { :class => klass, :name => name }
      end

      def commands
        config.commands
      end

      def app
        instance.app
      end

      def paths
        instance.paths
      end

      def callbacks
        instance.callbacks
      end

      def callback(name, &block)
        key = name.to_sym
        callbacks[name] ||= []
        callbacks[name].push block
      end
    end

    def config
      @config ||= Configuration.new
    end

    def app
      @app ||= AppProxy.new
    end

    def paths
      @paths ||= PathSet.new self.class.called_from
    end

    def callbacks
      config.callbacks
    end
  end
end

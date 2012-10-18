require 'active_support/core_ext/class/attribute'

module Iridium
  # A placeholder for iridium specific components
  class Component < Hydrogen::Component 
    ABSTRACT_COMPONENTS = %w(Iridium::Component Iridium::Engine Iridium::Application)

    class << self
      def loaded
        Hydrogen::Component.loaded
      end

      def subclasses
        loaded.select { |f| f <= self }
      end

      def inherited(base)
        return if base.abstract?

        super
        base.called_from = File.dirname(caller.detect { |l| l !~ /lib\/iridium/ })
      end

      def abstract?
        ABSTRACT_COMPONENTS.include?(name)
      end
    end
  end
end

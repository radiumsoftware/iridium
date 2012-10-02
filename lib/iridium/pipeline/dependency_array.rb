module Iridium
  module Pipeline
    class DependencyArray < Array
      def load(*names)
        names.each do |name|
          self << name
        end
      end

      def unload(*names)
        names.each do |name|
          delete name
        end
      end

      def swap(existing, replacement)
        return unless include? existing

        self[index(existing)] = replacement
      end
    end
  end
end

module Iridium
  module Pipeline
    class DependencyArray
      attr_reader :skips

      def initialize
        @files = []
        @skips = []
      end

      def load(*names)
        names.each do |name|
          @files << name
        end
      end

      def unload(*names)
        names.each do |name|
          @files.delete name
        end
      end

      def swap(existing, replacement)
        return unless files.include? existing
        skip existing
        @files[@files.index(existing)] = replacement
      end

      def skip(*names)
        names.each do |name|
          @skips << name
        end
      end

      def files
        @files - skips
      end

      def clear
        skips.clear
        @files.clear
      end

      def <<(file)
        @files << file
      end

      def each(&block)
        files.each &block
      end
    end
  end
end

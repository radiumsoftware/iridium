module Hydrogen
  class PathSet < ::Hash
    def initialize(root)
      @root = root

      raise Hydrogen::IncorrectRoot, "#{root} does not exist" unless File.exists? root

      super()
    end

    def add(key)
      self[key] = Path.new @root
    end

    class Path < ::Array
      class Entry < Struct.new(:path, :options) ; end

      def initialize(root)
        @root = root
        super()
      end

      def add(path, options = {})
        push Entry.new(path, options)
      end

      def expanded
        map do |entry|
          base = File.expand_path entry.path, @root

          if glob = entry.options[:glob]
            Dir["#{base}/#{glob}"]
          else
            base
          end
        end.flatten.uniq
      end

      def directories
        expanded.select { |f| File.directory? f }
      end

      def files
        expanded.select { |f| File.exists? f }
      end
    end
  end
end

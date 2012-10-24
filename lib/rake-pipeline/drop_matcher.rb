module Rake
  class Pipeline
    class DropMatcher < Matcher
      attr_accessor :block

      def output_files
        input_files.reject do |f|
          if block
            block.call f
          else
            f.path =~ @pattern
          end
        end
      end
    end
  end
end

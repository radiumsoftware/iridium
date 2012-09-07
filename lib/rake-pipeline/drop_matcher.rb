module Rake
  class Pipeline
    class DropMatcher < Matcher
      def output_files
        input_files.reject { |f| f.path =~ @pattern }
      end
    end
  end
end

module Rake
  class Pipeline
    class InjectionMatcher < Matcher
      # Allow every file
      def eligible_input_files
        input_files
      end

      # Filters will use instead to connect inputs
      def globbed_files
        input_files.select do |file|
          file.path =~ @pattern
        end
      end
    end
  end
end

module Rake
  class Pipeline
    class SortedPipeline < Pipeline
      attr_accessor :sorter, :pipeline

      def output_files
        input_files.sort(&sorter)
      end
    end
  end
end

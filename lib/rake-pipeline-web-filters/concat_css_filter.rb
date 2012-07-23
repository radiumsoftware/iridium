module Rake::Pipeline::Web::Filters
  class ConcatCssFilter < Rake::Pipeline::ConcatFilter
    def generate_output(inputs, output)
      sorted = inputs.sort do |file1, file2| 
        if (file1.path =~ /vendor/ && file2.path =~ /vendor/) || (file1.path !~ /vendor/ && file2.path !~ /vendor/)
          File.basename(file1.path, ".css") <=> File.basename(file2.path, ".css")
        elsif file2.path =~ /vendor/ && file1.path !~ /vendor/
          1
        else
          -1
        end
      end

      sorted.each do |input|
        output.write input.read
      end
    end
  end

  module PipelineHelpers
    def concat_css(*args, &block)
      filter(Rake::Pipeline::Web::Filters::ConcatCssFilter, *args, &block)
    end
  end
end

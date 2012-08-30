module Rake::Pipeline::Web::Filters
  class IifeFilter < Rake::Pipeline::Filter
    def generate_output(inputs, output)
      inputs.each do |input|
        output.write "(function() {\n"
        output.write input.read
        output.write "})();\n"
      end
    end
  end

  module PipelineHelpers
    def iife(*args, &block)
      filter(Rake::Pipeline::Web::Filters::IifeFilter, *args, &block)
    end
  end
end

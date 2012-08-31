module Rake::Pipeline::Web::Filters
  class ErbFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    def initialize(binding, &block)
      @binding = binding
      block ||= proc { |input| input.gsub(/\.erb$/, '') }
      super(&block)
    end

    def generate_output(inputs, output)
      inputs.each do |input|
        output.write ERB.new(input.read).result(@binding)
      end
    end

    def external_dependencies
      [ "erb" ]
    end
  end

  module PipelineHelpers
    def erb(*args, &block)
      filter(Rake::Pipeline::Web::Filters::ErbFilter, *args, &block)
    end
  end
end

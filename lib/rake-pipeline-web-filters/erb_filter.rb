module Rake::Pipeline::Web::Filters
  class ErbFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    def initialize(options = {}, &block)
      block ||= proc { |input| input.gsub(/\.erb$/, '') }
      super(&block)
      @options = options
    end

    def generate_output(inputs, output)
      inputs.each do |input|
        output.write ERB.new(input.read).result(@options[:binding])
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

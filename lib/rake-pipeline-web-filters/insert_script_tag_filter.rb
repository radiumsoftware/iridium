module Rake::Pipeline::Web::Filters
  class InjectionMatcher < Rake::Pipeline::Matcher
    def target=(value)
      @target = value
    end

    def output_files
      super.select { |f| f.path == @target }
    end

    def eligible_input_files
      input_files.select do |file|
        file.path =~ @pattern || file.path == @target
      end
    end
  end

  class InsertScriptTagFilter < Rake::Pipeline::Filter
    def initialize(target, &block)
      @target = target
      block = proc { target }
      super &block
    end

    def generate_output(inputs, output)
      inputs.each do |input|
        output.write input.read
      end
    end
  end

  module PipelineHelpers
    def insert_script_tag(glob, target)
      matcher = pipeline.copy Rake::Pipeline::Web::Filters::InjectionMatcher do
        filter Rake::Pipeline::Web::Filters::InsertScriptTagFilter, [target]
      end

      matcher.glob = glob
      matcher.target = target
      pipeline.add_filter matcher
      matcher
    end
  end
end

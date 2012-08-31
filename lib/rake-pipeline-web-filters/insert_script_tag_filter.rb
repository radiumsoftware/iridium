module Rake::Pipeline::Web::Filters
  class InjectionMatcher < Rake::Pipeline::Matcher
    def target=(value)
      @target = value
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
      target = target_from_inputs(inputs)

      original_content = target_from_inputs(inputs).read

      target.create do 
        # This simply wipes the file so it can be completely
        # overwritten with the new content. Since the output is the same
        # as the input file it needs to be empty otherwise the output
        # will contain the input file
      end

      script_tags = inputs_to_inject(inputs).map(&:read).join("\n")

      output.write original_content.gsub(%r{<head>(.+)</head>}m, "<head>\\1#{script_tags}</head>")
    end

    def inputs_to_inject(inputs)
      inputs.reject { |input| input.path == @target }
    end

    def target_from_inputs(inputs)
      inputs.select { |input| input.path == @target }.shift
    end
  end

  module PipelineHelpers
    def insert_script_tag(glob, target)
      matcher = pipeline.copy Rake::Pipeline::Web::Filters::InjectionMatcher do
        filter Rake::Pipeline::Web::Filters::InsertScriptTagFilter, target
      end

      matcher.glob = glob
      matcher.target = target
      pipeline.add_filter matcher
      matcher
    end
  end
end

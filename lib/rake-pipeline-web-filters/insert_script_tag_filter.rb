module Rake::Pipeline::Web::Filters
  class InjectionMatcher < Rake::Pipeline::Matcher
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

  class InjectionFilter < Rake::Pipeline::Filter
    def initialize(target, &block)
      @target = target
      block = proc { target }
      super &block
    end

    def generate_output(inputs, output)
      # Since everything goes through here we need to asset
      # that we actually have files to work with
      return if inputs_to_inject(inputs).empty?

      # Same thing as here. The target may have only been built
      # by a previous filter that was no invoked in this build.
      target = target_from_inputs(inputs)
      return unless target

      original_content = target_from_inputs(inputs).read

      target.create do 
        # This simply wipes the file so it can be completely
        # overwritten with the new content. Since the output is the same
        # as the input file it needs to be empty otherwise the output
        # will contain the input file
      end

      inject inputs, original_content, output
    end

    def inject(inputs, content, output)
      output.write content
    end

    def inputs_to_inject(inputs)
      globbed_files = pipeline.globbed_files.map(&:path)

      inputs.select { |input| globbed_files.find input.path }
    end

    def target_from_inputs(inputs)
      inputs.select { |input| input.path == @target }.shift
    end
  end

  class InsertScriptTagFilter < InjectionFilter
    def inject(inputs, source, output)
      script_tags = inputs_to_inject(inputs).map(&:read).join("\n")

      output.write source.gsub(%r{<head>(.+)</head>}m, "<head>\\1#{script_tags}</head>")
    end
  end

  module PipelineHelpers
    def inject(glob, &block)
      matcher = pipeline.copy InjectionMatcher, &block
      matcher.glob = glob
      pipeline.add_filter matcher
      matcher
    end

    def insert_script_tag(target)
      filter Rake::Pipeline::Web::Filters::InsertScriptTagFilter, target
    end
  end
end

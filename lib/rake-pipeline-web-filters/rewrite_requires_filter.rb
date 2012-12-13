module Rake::Pipeline::Web::Filters
  class RewriteRequiresFilter < Rake::Pipeline::Filter
    def generate_output(inputs, output)
      inputs.each do |input|
        code = input.read

        code.gsub! %r{^\s*require\s*\(\s*}, 'minispade.require('
        code.gsub! %r{^\s*requireAll\s*\(\s*}, 'minispade.requireAll('

        output.write code
      end
    end
  end

  module PipelineHelpers
    def rewrite_requires(*args, &block)
      filter(Rake::Pipeline::Web::Filters::RewriteRequiresFilter, *args, &block)
    end
  end
end

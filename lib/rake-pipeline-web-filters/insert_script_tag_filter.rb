module Rake::Pipeline::Web::Filters
  class InsertScriptTagFilter < Rake::Pipeline::InjectionFilter
    def inject(inputs, source, output)
      script_tags = inputs.map(&:read).join("\n")

      output.write source.gsub(%r{<head>(.+)</head>}m, "<head>\\1#{script_tags}</head>")
    end
  end

  module PipelineHelpers
    def insert_script_tag(target)
      filter Rake::Pipeline::Web::Filters::InsertScriptTagFilter, target
    end
  end
end

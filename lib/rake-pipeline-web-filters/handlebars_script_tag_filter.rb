module Rake::Pipeline::Web::Filters
  class HandlebarsScriptTagFilter < Rake::Pipeline::Filter
    def initialize(options={}, &block)
      # Convert .handlebars file extensions to .js
      block ||= proc { |input| "#{input}.script_tag" }
      options[:template_name] ||= proc { |input| input.sub(/handlebars|hbs/, '') }
      super(&block)
      @options = options
    end

    def generate_output(inputs, output)
      inputs.each do |input|
        name = @options[:template_name].call input.path
        output.write %Q{<script type="text/x-handlebars" data-template-name="#{name}">\n}
        output.write input.read
        output.write "</script>\n"
      end
    end
  end

  module PipelineHelpers
    def handlebars_script_tag(*args, &block)
      filter(Rake::Pipeline::Web::Filters::HandlebarsScriptTagFilter, *args, &block)
    end
  end
end

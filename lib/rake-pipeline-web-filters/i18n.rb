module Rake::Pipeline::Web::Filters
  class I18nFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    def initialize(string=nil, &block)
      block = proc { string } if string
      super(&block)
    end

    def generate_output(inputs, output)
      hash = {}

      inputs.each do |input|
        hash.merge! YAML.load(input.read)
      end

      output.write "I18n.translations = #{JSON.pretty_generate(hash)}"
    end

    def external_dependencies
      [ "erb", "json" ]
    end
  end

  module PipelineHelpers
    def i18n(*args, &block)
      filter(Rake::Pipeline::Web::Filters::I18nFilter, *args, &block)
    end
  end
end

module Rake::Pipeline::Web::Filters
  # A filter that ERB's each file and provides the Server config to templates
  class ErbFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    class Template
      def initialize(config)
        @config = config
      end

      def config
        @config
      end

      def locals
        binding
      end
    end

    def initialize(options = {}, &block)
      block ||= proc { |input| input.gsub('.erb', '') }
      super(&block)
      @options = options
    end

    def generate_output(inputs, output)
      template = Template.new @options[:config]

      inputs.each do |input|
        output.write ERB.new(input.read).result(template.locals)
      end
    end

    def external_dependencies
      [ "erb" ]
    end
  end

  module Helpers
    def erb(*args, &block)
      filter(Rake::Pipeline::Web::Filters::ErbFilter, *args, &block)
    end
  end
end

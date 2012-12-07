module Rake::Pipeline::Web::Filters
  # A filter that wraps input files in an IIFE (immediately invoked functional expression)
  #
  #
  # @example
  #   !!!ruby
  #   Rake::Pipeline.build do
  #     input "app/assets", "**/*.js"
  #     output "public"
  #
  #     # Wrap each file in: (function() { ... })();"
  #     filter Rake::Pipeline::Web::Filters::IifeFilter
  #   end
  class IifeFilter < Rake::Pipeline::Filter
    # @param [Proc] block a block to use as the Filter's
    #   {#output_name_generator}.
    def initialize(options = {}, &block)
      @options = options
      block ||= proc { |input| input }
      super(&block)
    end

    # Implement the {#generate_output} method required by
    # the {Filter} API. Wraps each input in an IIFE.
    # 
    # @param [Array<FileWrapper>] inputs an Array of
    #   {FileWrapper} objects representing the inputs to
    #   this filter.
    # @param [FileWrapper] output a single {FileWrapper}
    #   object representing the output.
    def generate_output(inputs, output)
      inputs.each do |input|
        output.write "(function() {\n"
        output.write input.read.chomp

        if @options[:source_map]
          output.write "\n})();//@ sourceURL=#{input.path}"
        else
          output.write "\n})();"
        end
      end
    end
  end
end

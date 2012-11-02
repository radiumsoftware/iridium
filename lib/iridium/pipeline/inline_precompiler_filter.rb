module Iridium
  module Pipeline
    class InlinePrecompilerFilter < ::Rake::Pipeline::Filter
      def generate_output(inputs, output)
        inputs.each do |input|
          precompiled_content = input.read.gsub(/Handlebars\.compile\(.+\)/) do |match|
            InlineHandlebarsPrecompiler.call $1
          end

          output.write precompiled_content
        end
      end
    end
  end
end

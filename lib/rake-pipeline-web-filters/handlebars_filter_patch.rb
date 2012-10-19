module Rake::Pipeline::Web::Filters
  class HandlebarsFilter
    def generate_output(inputs, output)
      inputs.each do |input|
        # The name of the template is the filename, sans extension
        name = options[:key_name_proc].call(input)

        # Read the file and escape it so it's a valid JS string
        source = input.read.to_json
        source = options[:precompiler].call(source) if options[:precompile] && options[:precompiler]

        # Write out a JS file, saved to target, wrapped in compiler
        output.write "#{options[:target]}['#{name}']=#{options[:wrapper_proc].call(source)}"
      end
    end
  end
end

module Rake::Pipeline::Filters
  class PrependFilter < Rake::Pipeline::Filter
    def generate_output(inputs, output)
      output.write prepend

      inputs.each do |input|
        output.write input.read
      end
    end

    def prepend
      " "
    end
  end
end

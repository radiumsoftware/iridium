module Rake::Pipeline::Web::Filters
  class SassFilter
    def additional_dependencies(input)
      engine = Sass::Engine.new(input.read, sass_options_for_file(input))
      engine.dependencies.map do |dep| 
        filename = dep.options[:filename]

        if filename =~ /\.png$/
          Compass::SpriteImporter.files filename
        else
          filename
        end
      end.flatten
    end
  end
end

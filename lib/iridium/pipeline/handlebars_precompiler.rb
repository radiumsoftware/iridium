module Iridium
  module Pipeline
    class HandlebarsPrecompiler < ::Barber::Precompiler
      def initialize(app = Iridium.application)
        @app = app
      end

      def handlebars
        raise "Cannot find handlebars file!" unless handlebars_file

        @handlebars ||= File.new(handlebars_file)
      end

      def handlebars_file
        @handlebars_file ||= @app.handlebars_path
      end
    end
  end
end

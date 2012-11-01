module Iridium
  class HandlebarsPrecompiler < ::Barber::Precompiler
    def handlebars
      @handlebars ||= File.new(Iridium.vendor_path.join('handlebars.js'))
    end
  end
end

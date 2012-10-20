module Iridium
  class HandlebarsPrecompiler
    def self.call(template)
      new.compile(template)
    end

    def compile(template)
      precompiled_template = context.call 'Handlebars.precompile', template
      "Handlebars.template(#{precompiled_template});"
    end

    def context
      @context ||= ExecJS.compile source
    end

    def source
      @source ||= File.read(Iridium.vendor_path.join('handlebars.js'))
    end
  end
end

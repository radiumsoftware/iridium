module Iridium
  class HandlebarsCompiler
    def self.call(template)
      new.compile(template)
    end

    def compile(template)
      context.call 'Handlebars.precompile', template
    end

    def context
      @context ||= ExecJS.compile source
    end

    def source
      @source ||= File.read(Iridium.vendor_path.join('handlebars.js'))
    end
  end
end

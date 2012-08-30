module Iridium
  class HandlebarsCompiler
    def initialize(source, template)
      @source, @template = source, template
    end

    def compile(options = {})
      context.call 'Handlebars.precompile', @template
    end

    def context
      @context ||= ExecJS.compile @source
    end
  end
end

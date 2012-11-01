module Iridium
  module Pipeline
    class InlineHandlebarsPrecompiler < ::Barber::InlinePrecompiler
      class << self
        def compile(template)
          HandlebarsPrecompiler.compile template
        end
      end
    end

    class HandlebarsFilePrecompiler < InlineHandlebarsPrecompiler
      class << self
        def call(template)
          "#{super};"
        end
      end
    end
  end
end

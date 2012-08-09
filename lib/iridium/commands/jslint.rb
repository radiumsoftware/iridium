module Iridium
  module Commands
    class JSLint
      class << self
        def start(args = ARGV)
          options = {}

          if args.size == 0
            args = Dir['app/javascripts/**/*.js']
          end

          JSLintRunner.execute args
        end
      end
    end
  end
end

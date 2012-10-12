module Iridium
  module JSLint
    class LintCommand
      class << self
        def start(args = ARGV)
          if args.size == 0
            args = Dir['app/javascripts/**/*.js']
          end

          JSLintRunner.execute args
        end
      end
    end
  end
end

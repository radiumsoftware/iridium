module Iridium
  module JSLint
    class LintCommand < Hydrogen::Command
      description "Run jslint on some files"

      desc "lint FILES", "lint the specified files"
      def lint(*files)
        if files.size == 0
          files = Dir['app/javascripts/**/*.js']
        end

        JSLintRunner.execute files
      end
    end
  end
end

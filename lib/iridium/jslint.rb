require 'iridium/jslint/linter'
require 'iridium/jslint/lint_command'
require 'iridium/jslint/report'
require 'iridium/jslint/runner'

module Iridium
  module JSLint
    class Component < Hydrogen::Component
      command LintCommand
    end
  end
end

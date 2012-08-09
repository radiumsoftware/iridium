module Iridium
  module Commands
    class JSLint
      class << self
        def start(args = ARGV)
          options = {}

          unless Iridium.application
            begin
              require './application.rb'
            rescue LoadError
              $stderr.puts "Could not find application.rb. Navigate to the root of your Iridium app"
              exit 2
            end
          end

          JSLintRunner.execute args
        end
      end
    end
  end
end

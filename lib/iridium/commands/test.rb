require 'optparse'

module Iridium
  module Commands
    class Test
      class << self
        def start(args = ARGV)
          options = {}

          OptionParser.new do |opts|
            opts.banner = "Usage: PATH [PATH] [options]"

            opts.on "--debug", "Print messages from tests"  do |d|
              options[:debug] = true
            end

            # No argument, shows at tail.  This will print an options summary.
            # Try it and see!
            opts.on_tail("-h", "--help", "Show this message") do
              puts opts
              exit
            end
          end.parse! args

          TestSuite.execute args, options
        end
      end
    end
  end
end

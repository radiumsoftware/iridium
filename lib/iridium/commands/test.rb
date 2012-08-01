module Iridium
  module Commands
    class Test
      class << self
        def start(file_names = ARGV, options = {})
          TestSuite.execute file_names, options
        end
      end
    end
  end
end

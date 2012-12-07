require 'iridium/testing/test_command'

module Iridium
  module Testing
    class TestingComponent < Component
      command TestCommand
    end
  end

  class << self
    def phantom_js_test_runner
      File.expand_path '../testing/phantomjs/run_tests.coffee', __FILE__
    end
  end
end

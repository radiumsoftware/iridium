require 'iridium/testing/message'
require 'iridium/testing/logging_result_collector'
require 'iridium/testing/result_collector'
require 'iridium/testing/test_command'
require 'iridium/testing/command_streamer'
require 'iridium/testing/runner'
require 'iridium/testing/suite'
require 'iridium/testing/report'
require 'iridium/testing/result'

module Iridium
  module Testing
    class TestingComponent < Component
      command TestCommand
    end
  end
end

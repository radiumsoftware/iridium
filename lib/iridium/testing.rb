require 'iridium/testing/test_command'
require 'iridium/testing/command_streamer'
require 'iridium/testing/runner'
require 'iridium/testing/suite'
require 'iridium/testing/report'
require 'iridium/testing/result'

module Iridium
  module Testing
    class Component < Hydrogen::Component
      command TestCommand
    end
  end
end

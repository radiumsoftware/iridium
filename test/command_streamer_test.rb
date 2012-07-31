require 'test_helper'

class CommandStreamerTest < MiniTest::Unit::TestCase
  def test_nothing_is_raised_when_command_works
    command = Iridium::CommandStreamer.new "echo hi"
    command.run
  end

  def test_raises_an_error_when_command_failes
    command = Iridium::CommandStreamer.new "ls /foo/bar"

    assert_raises Iridium::CommandStreamer::CommandFailed do
      command.run
    end
  end

  def test_survives_when_command_cannot_be_found
    command = Iridium::CommandStreamer.new "asdfoijdafkdasjf"

    assert_raises Iridium::CommandStreamer::CommandFailed do
      command.run
    end
  end
end

require 'test_helper'
require 'shellwords'

class CommandStreamerTest < MiniTest::Unit::TestCase
  def test_nothing_is_raised_when_command_works
    command = Iridium::CommandStreamer.new "echo hi"
    command.run
  end

  def test_raises_an_error_when_command_fails
    script_path = File.expand_path "../../script/fail", __FILE__

    command = Iridium::CommandStreamer.new script_path

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

  def test_passes_message_back_to_iridium
    json = {:iridium => {:this => :message}}.to_json
    collector = []

    command = Iridium::CommandStreamer.new "echo #{Shellwords.shellescape(json)}"
    command.run do |message|
      collector << message
    end

    assert_equal 1, collector.size
    assert_equal({
      "this" => "message"
    }, collector.first)
  end

  def test_raises_an_error_when_process_sends_an_abort_signal
    json = {:abort => "Failed"}.to_json

    command = Iridium::CommandStreamer.new "echo #{Shellwords.shellescape(json)}"

    assert_raises Iridium::CommandStreamer::ProcessAborted do
      command.run do
        # do nothing, block required to accept messages
      end
    end
  end
end

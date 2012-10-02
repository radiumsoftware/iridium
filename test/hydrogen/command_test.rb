require 'test_helper'

class Hydrogen::CommandTest < MiniTest::Unit::TestCase
  def test_commands_work_like_thor_commands
    command = Class.new Hydrogen::Command do
      desc "hello NAME", "Prints out a greeting to NAME"
      def hello(name)
        puts "Yo #{name}! What's up?"
      end
    end

    stdout, stderr = capture_io do
      command.new.invoke :hello, ["Adam"]
    end

    assert_includes stdout, "Adam"
  end

  def test_commands_have_a_description
    command = Class.new Hydrogen::Command do
      description "This is what I do!"
    end

    assert_equal "This is what I do!", command.description_banner
  end
end

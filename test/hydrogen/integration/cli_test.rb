require 'test_helper'

class Hydrogen::CLITest < MiniTest::Unit::TestCase
  def test_registered_commands_are_available_in_the_cli
    greeter = Class.new Hydrogen::Command do
      description "Greets people!"

      desc "greet NAME", "print a greeting for NAME"
      def greet(name)
        puts "Yo #{name}!"
      end
    end

    greeter_component = Class.new Hydrogen::Component do
      command greeter, :greeter
    end

    cli = Class.new Hydrogen::CLI

    stdout, stderr = capture_io do
      cli.new.invoke :greeter, ["greet", "Adam"]
    end

    assert_includes stdout, "Adam"
  end
end

require 'test_helper'

class CLITest < GeneratorTestCase
  def invoke(args)
    Dir.chdir destination_root do
      capture_io { Iridium::CLI.start args }
    end
  end

  def test_delegates_to_the_application_developer
    invoke %w[new application todos]

    assert_file destination_root.join("todos")
  end
end

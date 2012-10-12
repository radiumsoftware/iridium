require 'test_helper'

class CLITest < GeneratorTestCase
  def desination_root
    Pathname.new(File.expand_path('../sandbox', __FILE__))
  end

  def invoke(args)
    stdout, stderr = nil, nil

    Dir.chdir destination_root do
      stdout, stderr = capture_io { Iridium::CLI.start args }
    end

    return stdout, stderr
  end

  def test_delegates_to_the_application_developer
    skip

    invoke %w[app todos]

    assert_file destination_root.join("todos")
  end
end

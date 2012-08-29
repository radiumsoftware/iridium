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
    invoke %w[app todos]

    assert_file destination_root.join("todos")
  end

  def test_compile_generates_a_site
    create_file "app/javascripts/app.js", "FOO"

    invoke %w[compile]

    assert File.exists?(Iridium.application.site_path.join('application.js'))
  end

  def test_compile_accepts_an_optional_path_argument
    create_file "app/javascripts/app.js", "FOO"

    output_root = destination_root.join 'foo'

    invoke ['compile', output_root.to_s]

    assert_file "foo/application.js"
  end
end

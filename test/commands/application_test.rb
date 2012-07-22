require 'test_helper'
require 'pathname'
require 'iridium/commands/application'

class ApplicationCommandTest < MiniTest::Unit::TestCase
  def setup
    FileUtils.rm_rf destination_root
  end

  def command
    Iridium::Commands::Application
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def read(path)
    File.read(path)
  end

  def invoke(*args)
    options = args.extract_options!
    runner = command.new args, options
    runner.destination_root = destination_root
    capture(:stdout) { runner.invoke :application }
  end

  def destination_root
    Pathname.new(File.expand_path('../../sandbox', __FILE__))
  end

  def tests_generates_an_app_skeleton
    invoke 'todos'

    assert File.exists?(destination_root.join('todos'))

    assert File.exists?(destination_root.join('todos', 'app'))
    assert File.exists?(destination_root.join('todos', 'app', 'images'))
    assert File.exists?(destination_root.join('todos', 'app', 'stylesheets'))
    assert File.exists?(destination_root.join('todos', 'app', 'vendor', 'javascripts'))
    assert File.exists?(destination_root.join('todos', 'app', 'vendor', 'stylesheets'))

    assert File.exists?(destination_root.join('todos', 'app', 'dependencies'))

    assert File.exists?(destination_root.join('todos', 'app', 'public', 'index.html.erb'))

    assert File.exists?(destination_root.join('todos', 'config', 'development.rb'))
    assert File.exists?(destination_root.join('todos', 'config', 'test.rb'))
    assert File.exists?(destination_root.join('todos', 'config', 'production.rb'))

    assert File.directory?(destination_root.join('todos', 'site'))
  end

  def test_generated_application_contains_file
    invoke 'todos'

    content = read destination_root.join('todos', 'application.rb')

    assert_includes content, 'Todos'
  end

  def test_generated_applications_can_be_deployed
    invoke 'todos', :deployable => true

    assert File.exists?(destination_root.join('todos', 'config.ru'))

    content = read destination_root.join('todos', 'config.ru')

    assert_includes content, 'run Todos'
  end

  def test_generated_index_loads_minispade_module
    invoke 'todos'

    index_path = destination_root.join('todos', 'app', 'public', 'index.html.erb')

    assert File.exists?(index_path)
    content = read index_path

    assert_includes content, %Q{minispade.require("todos/app");}
  end
end

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

  def assert_file(*path)
    full_path = destination_root.join *path

    assert File.exists?(full_path), 
      "#{full_path} should be a file. Current Files: #{Dir[destination_root.join("**", "*").inspect]}"
  end

  def destination_root
    Pathname.new(File.expand_path('../../sandbox', __FILE__))
  end

  def tests_generates_an_app_skeleton
    invoke 'todos'

    assert_file 'todos'

    assert_file 'todos', 'app'
    assert_file 'todos', 'app', 'images'
    assert_file 'todos', 'app', 'stylesheets'
    assert_file 'todos', 'app', 'vendor', 'javascripts'
    assert_file 'todos', 'app', 'vendor', 'stylesheets'

    assert_file 'todos', 'app', 'dependencies'

    assert_file 'todos', 'app', 'public'

    assert_file 'todos', 'config', 'development.rb'
    assert_file 'todos', 'config', 'test.rb'
    assert_file 'todos', 'config', 'production.rb'

    assert_file 'todos', 'site'
  end

  def test_generated_application_contains_file
    invoke 'todos'

    content = read destination_root.join('todos', 'application.rb')

    assert_includes content, 'Todos'
  end

  def test_assetfile_is_optional
    invoke 'todos', :assetfile => true

    assert_file 'todos', 'Assetfile'
  end

  def test_generated_applications_can_be_deployed
    invoke 'todos', :deployable => true

    assert_file 'todos', 'config.ru'

    content = read destination_root.join('todos', 'config.ru')

    assert_includes content, 'run Todos'
  end

  def test_generated_index_loads_assets
    invoke 'todos', :index => true

    assert_file 'todos', 'app', 'public', 'index.html.erb'
    index_path = destination_root.join('todos', 'app', 'public', 'index.html.erb')
    content = read index_path

    assert_includes content, %Q{<script src="/application.js"></script>}
    assert_includes content, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes content, %Q{minispade.require("todos/app");}
  end
end

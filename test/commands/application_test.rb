require 'test_helper'
require 'pathname'
require 'iridium/commands/application'

class ApplicationCommandTest < GeneratorTestCase
  def command
    Iridium::Commands::Application
  end

  def tests_generates_an_app_skeleton
    ENV['stop'] = "1"

    invoke 'application', 'todos'

    assert_file 'todos'

    assert_file 'todos', 'app'
    assert_file 'todos', 'app', 'images'
    assert_file 'todos', 'app', 'stylesheets'
    assert_file 'todos', 'app', 'vendor', 'javascripts'
    assert_file 'todos', 'app', 'vendor', 'stylesheets'
    assert_file 'todos', 'app', 'dependencies'
    assert_file 'todos', 'app', 'public'

    assert_file 'todos', 'test', 'helper.coffee'
    assert_file 'todos', 'test', 'integration', 'navigation_test.coffee'
    assert_file 'todos', 'test', 'unit', 'truth_test.coffee'
    assert_file 'todos', 'test', 'support', 'qunit.js'
  
    assert_file 'todos', 'site'

    assert_file 'todos', 'application.rb'

    content = read destination_root.join('todos', 'application.rb')

    assert_includes content, 'Todos'
    assert_includes content, %Q{config.load :minispade}

    assert_file 'todos', 'app', 'dependencies', 'minispade.js'
  end

  def test_assetfile_is_optional
    invoke 'application', 'todos', :assetfile => true

    assert_file 'todos', 'Assetfile'
  end

  def test_generated_applications_can_be_deployed
    invoke 'application', 'todos', :deployable => true

    assert_file 'todos', 'config.ru'

    content = read destination_root.join('todos', 'config.ru')

    assert_includes content, 'run Todos'
  end

  def test_generated_applications_support_different_envs
    invoke 'application', 'todos', :envs => true

    assert_file 'todos', 'config', 'development.rb'
    assert_file 'todos', 'config', 'test.rb'
    assert_file 'todos', 'config', 'production.rb'

    assert_file 'todos', 'config', 'settings.yml'
  end

  def test_generated_index_loads_assets
    invoke 'application', 'todos', :index => true

    assert_file 'todos', 'app', 'public', 'index.html.erb'
    index_path = destination_root.join('todos', 'app', 'public', 'index.html.erb')
    content = read index_path

    assert_includes content, %Q{<script src="/application.js"></script>}
    assert_includes content, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes content, %Q{minispade.require("todos/app");}
  end
end

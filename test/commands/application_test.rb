require 'test_helper'

class ApplicationCommandTest < GeneratorTestCase
  def command
    Iridium::Commands::Application
  end

  def tests_generates_an_app_skeleton
    invoke 'application', 'todos'

    assert_file 'todos'

    assert_file 'todos', 'app'
    assert_file 'todos', 'app', 'assets', 'images'

    assert_file 'todos', 'app', 'stylesheets', 'app.scss'

    assert_file 'todos', 'app', 'javascripts', 'app.coffee'
    assert_file 'todos', 'app', 'javascripts', 'boot.coffee'

    assert_file 'todos', 'app', 'javascripts', 'models'
    assert_file 'todos', 'app', 'javascripts', 'views'
    assert_file 'todos', 'app', 'javascripts', 'controllers'

    assert_file 'todos', 'app', 'templates'

    assert_file 'todos', 'vendor', 'javascripts'
    assert_file 'todos', 'vendor', 'stylesheets'

    assert_file 'todos', 'app', 'locales', 'en.yml'

    assert_file 'todos', 'app', 'config', 'development.coffee'
    assert_file 'todos', 'app', 'config', 'production.coffee'
    assert_file 'todos', 'app', 'config', 'test.coffee'
    assert_file 'todos', 'app', 'config', 'initializers'

    assert_file 'todos', 'app', 'index.html.erb'

    assert_file 'todos', 'test', 'integration', 'navigation_test.coffee'
    assert_file 'todos', 'test', 'unit', 'truth_test.coffee'
    assert_file 'todos', 'test', 'models'
    assert_file 'todos', 'test', 'views'
    assert_file 'todos', 'test', 'controllers'
    assert_file 'todos', 'test', 'templates'
    assert_file 'todos', 'test', 'support', 'sinon.js'
    assert_file 'todos', 'test', 'support', 'helper.coffee'

    assert_file 'todos', 'site'

    assert_file 'todos', 'application.rb'

    assert_file 'todos', '.gitignore'

    assert_file 'todos', 'readme.md'

    content = read destination_root.join('todos', 'application.rb')

    assert_includes content, 'Todos < Iridium::Application'

    assert_includes content, %Q{config.load :minispade}
    assert_file 'todos', 'vendor', 'javascripts', 'minispade.js'

    assert_file 'todos', 'vendor', 'javascripts', 'handlebars.js'
    assert_file 'todos', 'vendor', 'javascripts', 'jquery.js'
    assert_file 'todos', 'vendor', 'javascripts', 'i18n.js'

    index_path = destination_root.join('todos', 'app', 'index.html.erb')
    content = read index_path

    assert_includes content, %Q{<script src="/application.js"></script>}
    assert_includes content, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes content, %Q{minispade.require("todos/boot");}
  end

  def test_accepts_a_path
    invoke 'application', 'my_apps/todos'

    assert_file 'my_apps/todos'

    assert_file 'my_apps/todos', 'app'

    content = read destination_root.join('my_apps', 'todos', 'application.rb')

    assert_includes content, 'Todos < Iridium::Application'
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
end

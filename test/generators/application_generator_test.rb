require 'test_helper'

class ApplicationCommandTest < GeneratorTestCase
  def command
    Iridium::Generators::ApplicationGenerator
  end

  def tests_generates_an_app_skeleton
    invoke 'application', 'todos'

    assert_file 'todos'

    assert_file 'todos', 'app'
    assert_file 'todos', 'app', 'assets', 'images'

    assert_file 'todos', 'app', 'sprites'

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
    assert_file 'todos', 'app', 'config', 'initializers', 'handlebars.coffee'

    assert_file 'todos', 'app', 'assets', 'index.html.erb'

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
    assert_file 'todos', 'config', 'environment.rb'

    assert_file 'todos', '.gitignore'

    assert_file 'todos', 'readme.md'

    assert_file 'todos', 'config', 'development.rb'
    assert_file 'todos', 'config', 'test.rb'
    assert_file 'todos', 'config', 'production.rb'

    assert_file 'todos', 'config', 'settings.yml'

    assert_file 'todos', 'vendor', 'javascripts', 'minispade.js'
    assert_file 'todos', 'vendor', 'javascripts', 'handlebars.js'
    assert_file 'todos', 'vendor', 'javascripts', 'jquery.js'
    assert_file 'todos', 'vendor', 'javascripts', 'i18n.js'
  end

  def test_application_enviroment_files
    invoke 'application', 'todos'
    content = read destination_root.join('todos', 'config', 'environment.rb')

    assert_includes content, %Q{require File.expand_path('../../application', __FILE__)}
    assert_includes content, %Q{Iridium.application.boot!}
  end

  def test_application_is_configured_correctly
    invoke 'application', 'todos'
    content = read destination_root.join('todos', 'application.rb')

    assert_includes content, 'Todos < Iridium::Application'
    assert_includes content, %Q{config.dependencies.load :minispade}
  end

  def test_html_file_loads_required_assets_and_code
    invoke 'application', 'todos'
    index_path = destination_root.join('todos', 'app', 'assets', 'index.html.erb')
    content = read index_path

    assert_includes content, %Q{<script src="/application.js"></script>}
    assert_includes content, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes content, %Q{minispade.require("todos/boot");}
  end

  def test_production_env_is_configured_correctly
    invoke 'application', 'todos'
    production_rb = destination_root.join("todos", "config", "production.rb")
    content = read production_rb

    assert_includes content, "config.pipeline.minify = true"
    assert_includes content, "config.pipeline.gzip = true"
    assert_includes content, "config.pipeline.manifest = true"
    assert_includes content, "config.handlebars.compiler = Iridium::HandlebarsPrecompiler"
    assert_includes content, "config.minispade.module_format = :function"
  end

  def test_accepts_a_path
    invoke 'application', 'my_apps/todos'

    assert_file 'my_apps/todos'

    assert_file 'my_apps/todos', 'app'

    content = read destination_root.join('my_apps', 'todos', 'application.rb')

    assert_includes content, 'Todos < Iridium::Application'
  end

  def test_generated_applications_support_different_envs
    invoke 'application', 'todos', :envs => true

    assert_file 'todos', 'config', 'development.rb'
    assert_file 'todos', 'config', 'test.rb'
    assert_file 'todos', 'config', 'production.rb'

    assert_file 'todos', 'config', 'settings.yml'
  end
end

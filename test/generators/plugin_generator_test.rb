require 'test_helper'

class PluginCommandTest < GeneratorTestCase
  def command
    Iridium::Generators::PluginGenerator
  end

  def tests_generates_an_app_skeleton
    invoke 'plugin', 'ember'

    assert_file 'ember'

    assert_file 'ember', 'app'
    assert_file 'ember', 'app', 'assets', 'images'

    assert_file 'ember', 'app', 'sprites'

    assert_file 'ember', 'app', 'stylesheets', 'ember.scss'

    assert_file 'ember', 'app', 'javascripts', 'ember.coffee'

    assert_file 'ember', 'app', 'javascripts', 'models'
    assert_file 'ember', 'app', 'javascripts', 'views'
    assert_file 'ember', 'app', 'javascripts', 'controllers'

    assert_file 'ember', 'app', 'templates'

    assert_file 'ember', 'vendor', 'javascripts'
    assert_file 'ember', 'vendor', 'stylesheets'

    assert_file 'ember', 'app', 'locales', 'en.yml'

    assert_file 'ember', 'app', 'config', 'development.coffee'
    assert_file 'ember', 'app', 'config', 'production.coffee'
    assert_file 'ember', 'app', 'config', 'test.coffee'
    assert_file 'ember', 'app', 'config', 'initializers'
  end

  def test_generates_ruby_code
    invoke 'plugin', 'ember'

    assert_file 'ember'

    assert_file 'ember', 'lib', 'ember.rb'
    assert_file 'ember', 'lib', 'ember', 'engine.rb'
    assert_file 'ember', 'lib', 'ember', 'version.rb'
    assert_file 'ember', 'Gemfile'
    assert_file 'ember', 'ember.gemspec'
  end

  def test_generates_documenation
    invoke 'plugin', 'ember'

    assert_file 'ember', 'readme.md'
    assert_file 'ember', 'LICENSE'
  end

  def test_generated_lib_file_requires_version
    invoke 'plugin', 'ember'
    assert_file 'ember', 'lib', 'ember.rb'

    content = read 'ember', 'lib', 'ember.rb'
    assert_includes content, %Q{require 'ember/version'}
  end

  def test_generated_lib_file_requires_files
    invoke 'plugin', 'ember'
    assert_file 'ember', 'lib', 'ember.rb'

    content = read 'ember', 'lib', 'ember.rb'
    assert_includes content, %Q{require 'iridium'}
    assert_includes content, %Q{require 'ember/engine'}
    assert_includes content, %Q{require 'ember/version'}
  end

  def test_generated_engine_file_declares_an_engine
    invoke 'plugin', 'ember'
    assert_file 'ember', 'lib', 'ember', 'engine.rb'

    content = read 'ember', 'lib', 'ember', 'engine.rb'
    assert_includes content, %Q{class Engine < Iridium::Engine}
  end
end

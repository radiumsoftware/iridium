require 'test_helper'

class ApplicationTest < MiniTest::Unit::TestCase
  def test_engine_initializers_are_loaded_before_app_initializers
    TestApp.configure do
      initializer do
        config.foos << :app
      end
    end

    engine = Class.new MockEngine do
      initializer do
        config.foos = [:engine]
      end
    end

    TestApp.new.boot!

    assert_kind_of Array, TestApp.config.foos
    assert_equal [:engine, :app], TestApp.config.foos
  end

  def test_engine_initializer_files_are_loaded_before_app_initializers
    create_file "external/config/initializers/engine.rb", <<-ruby
      TestApp.configure do
        config.results = [:engine]
      end
    ruby

    create_file "config/initializers/engine.rb", <<-ruby
      TestApp.configure do
        config.results << :app
      end
    ruby

    TestApp.new.boot!

    assert_kind_of Array, TestApp.config.results
    assert_equal [:engine, :app], TestApp.config.results
  end

  def test_settings_files_are_loaded
    create_file "config/settings.yml", <<-yml
      foo:
        bar
    yml

    TestApp.new.boot!

    assert_equal "bar", TestApp.config.settings.foo
  end

  def test_settings_with_with_env_keys_are_loaded
    create_file "config/settings.yml", <<-yml
      #{Iridium.env}:
        bar:
          baz
    yml

    TestApp.new.boot!

    assert_equal "baz", TestApp.config.settings.bar
  end

  def test_environment_specific_configuration_file_is_loaded
    create_file "config/#{Iridium.env}.rb", <<-ruby
      TestApp.configure do 
        config.dubstep = :noob
      end
    ruby

    TestApp.new.boot!

    assert_equal :noob, TestApp.config.dubstep
  end

  def test_raises_an_error_when_already_booted
    app = TestApp.new
    app.boot!

    assert_raises Iridium::AlreadyBooted do
      app.boot!
    end
  end

  def test_boot_sets_booted?
    app = TestApp.new

    app.boot!

    assert app.booted?
  end
end

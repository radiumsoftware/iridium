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

  def test_configuration_file_is_loaded
    create_file "config/application.rb", <<-ruby
      TestApp.configure do 
        config.trance = :awesome
      end
    ruby

    TestApp.new.boot!

    assert_equal :awesome, TestApp.config.trance
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
end

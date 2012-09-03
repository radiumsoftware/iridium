require 'test_helper'

class ConfigTest < MiniTest::Unit::TestCase
  def test_initializer
    config = Iridium::Config.new

    assert_kind_of Iridium::MiddlewareStack, config.middleware

    assert_equal Hash.new, config.proxies
  end

  def test_proxy
    config = Iridium::Config.new

    config.proxy '/api', 'foo.com'

    assert_equal 1, config.proxies.size
  end

  def test_proxy_allows_overwriting
    config = Iridium::Config.new

    config.proxy '/api', 'foo.com'

    assert_equal 'foo.com', config.proxies['/api']

    config.proxy '/api', 'bar.com'
    assert_equal 1, config.proxies.size
    assert_equal 'bar.com', config.proxies['/api']
  end

  def test_load_add_dependences
    config = Iridium::Config.new

    config.dependencies.load :foo

    assert_includes config.dependencies, :foo
  end

  def test_unload_removes_dependences
    config = Iridium::Config.new

    config.dependencies << :foo
    config.dependencies.unload :foo

    assert_empty config.dependencies
  end

  def test_swap_dependencies
    config = Iridium::Config.new

    config.dependencies.load :handlebars

    config.dependencies.swap :handlebars, :handlebars_runtime

    assert_includes config.dependencies, :handlebars_runtime
    refute_includes config.dependencies, :handlebars
  end
end

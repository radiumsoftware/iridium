require 'test_helper'

class ConfigTest < MiniTest::Unit::TestCase
  def test_initializer
    config = Iridium::Config.new

    assert_kind_of Iridium::MiddlewareStack, config.middleware

    assert_equal Hash.new, config.proxies
  end

  def test_default_cache_configuration
    config = Iridium::Config.new

    assert_equal 'public', config.cache_control

    assert_kind_of Dalli::Client, config.cache[:metastore]
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
end

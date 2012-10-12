require 'test_helper'

class RackTest < MiniTest::Unit::TestCase
  def setup
    super
    Iridium.application.config.proxies.clear
  end

  def teardown
    Iridium.application.config.proxies.clear
    super
  end

  def config
    Iridium.application.config
  end

  def test_middleware_config_is_exposed
    assert_kind_of Iridium::Rack::MiddlewareStack, config.middleware
  end

  def test_proxy_config_is_exposed
    assert_kind_of Hash, config.proxies
  end

  def test_proxy
    config.proxy '/api', 'foo.com'

    assert_equal "foo.com", config.proxies['/api']
  end

  def test_proxy_allows_overwriting
    config.proxy '/api', 'foo.com'

    assert_equal 'foo.com', config.proxies['/api']

    config.proxy '/api', 'bar.com'
    assert_equal 1, config.proxies.size
    assert_equal 'bar.com', config.proxies['/api']
  end
end

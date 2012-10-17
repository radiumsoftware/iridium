require 'test_helper'

class RackTest < MiniTest::Unit::TestCase
  def app
    Iridium.application
  end

  def proxies
    config.proxies
  end

  def setup
    super
    proxies.clear
  end

  def teardown
    proxies.clear
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
    app.configure do
      proxy '/api', 'foo.com'
    end

    assert_equal "foo.com", config.proxies['/api']
  end

  def test_proxy_allows_overwriting
    app.configure do
      proxy '/api', 'foo.com'
    end

    assert_equal 'foo.com', config.proxies['/api']

    app.configure do 
      proxy '/api', 'bar.com'
    end

    assert_equal 1, config.proxies.size
    assert_equal 'bar.com', config.proxies['/api']
  end
end

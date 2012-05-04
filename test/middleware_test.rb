require 'test_helper'

class MiddlewareTest < MiniTest::Unit::TestCase
  class MockApp
    def call(env = nil)
      [200, {}, ["hello"]]
    end
  end

  def test_add_cookie
    middleware = Iridium::Middleware::AddCookie.new MockApp.new, 'foo', 'bar'

    status, headers, body = middleware.call({})

    assert_equal "foo=bar", headers['Set-Cookie']
  end

  def test_adds_a_basic_header
    middleware = Iridium::Middleware::AddHeader.new MockApp.new, 'X-Foo', 'bar'

    env = {}
    middleware.call env

    assert_equal 'bar', env['HTTP_X_FOO']
  end

  def test_doesnt_blow_up_on_rack_style
    middleware = Iridium::Middleware::AddHeader.new MockApp.new, 'HTTP_X_FOO', 'bar'

    env = {}
    middleware.call env

    assert_equal 'bar', env['HTTP_X_FOO']
  end
end

require 'test_helper'

class MiddlewareStackTest < MiniTest::Unit::TestCase
  def test_add_header_shorcut
    stack = Iridium::Rack::MiddlewareStack.new

    stack.add_header 'foo', 'bar', :url => /api/

    assert_equal 1, stack.size
  end

  def test_add_cookie_shortuct
    stack = Iridium::Rack::MiddlewareStack.new

    stack.add_cookie 'foo', 'bar'

    assert_equal 1, stack.size
  end
end

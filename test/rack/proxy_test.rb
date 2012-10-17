require 'test_helper'

class ProxyTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestApp
  end

  def setup
    TestApp.configure do 
      proxy '/api', 'http://myapi.com'
    end
  end

  def test_forwards_to_proxy
    stub_request(:post, "http://myapi.com/foo").
      with(:body => {"foo" => "bar"}).
      to_return(:status => 200, :body => 'bar')

    post '/api/foo', :foo => :bar

    assert last_response.ok?

    assert_equal 'bar', last_response.body
  end

  def test_proxy_forwards_query_string
    stub_request(:get, "http://myapi.com/foo?bar=qux").
      to_return(:status => 200)

    get '/api/foo?bar=qux'

    assert last_response.ok?
  end

  def test_round_trips_headers
    stub_request(:get, "http://myapi.com/foo").with({
      :headers => {'X-My-Custom-Header' => 'foo'}
    }).to_return(:status => 200, :headers => {'X-My-Custom-Header' => 'bar'})

    get '/api/foo', {}, {'HTTP_X_MY_CUSTOM_HEADER' => 'foo'}

    assert last_response.ok?

    assert_equal 'bar', last_response.headers['X-My-Custom-Header']
  end

  def test_removes_content_headers_on_1xx
    stub_request(:get, "http://myapi.com/foo").to_return({
      :status => 100, :headers => {
        'Content-Type' => 'text/plain', 'Content-Length' => "5" 
      }
    })

    get '/api/foo'

    assert last_response

    assert_nil last_response.original_headers['Content-Length']
    assert_nil last_response.original_headers['Content-Type']
  end

  def test_removes_content_headers_on_205
    stub_request(:get, "http://myapi.com/foo").to_return({
      :status => 205, :headers => {
        'Content-Type' => 'text/plain', 'Content-Length' => "5" 
      }
    })

    get '/api/foo'

    assert last_response

    assert_nil last_response.original_headers['Content-Length']
    assert_nil last_response.original_headers['Content-Type']
  end

  def test_removes_content_headers_on_206
    stub_request(:get, "http://myapi.com/foo").to_return({
      :status => 206, :headers => {
        'Content-Type' => 'text/plain', 'Content-Length' => "5" 
      }
    })

    get '/api/foo'

    assert last_response

    assert_nil last_response.original_headers['Content-Length']
    assert_nil last_response.original_headers['Content-Type']
  end

  def test_removes_content_headers_on_304
    stub_request(:get, "http://myapi.com/foo").to_return({
      :status => 304, :headers => {
        'Content-Type' => 'text/plain', 'Content-Length' => "5" 
      }
    })

    get '/api/foo'

    assert last_response

    assert_nil last_response.original_headers['Content-Length']
    assert_nil last_response.original_headers['Content-Type']
  end
end

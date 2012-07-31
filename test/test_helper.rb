require 'simplecov'
SimpleCov.start

require 'minitest/unit'
require 'minitest/pride'
require 'minitest/autorun'

require 'rack/test'

require 'iridium'

require 'debugger'

require 'webmock/minitest'

WebMock.disable_net_connect!

ENV['IRIDIUM_ENV'] = 'test'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |file|
  require file
end

# Require the test app which lives in a separate directory
require File.expand_path("../app/application", __FILE__)

class StubApp
  def self.call(env)
    [200, {"Content-Type" => "text/html"}, ["<body>Hello World</body>"]]
  end
end

class StubServer < Rack::Server
  def app
    StubApp
  end
end

require 'thin'

Thin::Logging.silent = true

Thread.new do
  StubServer.new(:Port => 7776).start
end

sleep 1.5

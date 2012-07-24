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

ENV['RACK_ENV'] = 'test'

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each do |file|
  require file
end

# Require the test app which lives in a separate directory
require File.expand_path("../app/application", __FILE__)

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

class TestApp < Iridium::Application ; end
TestApp.root = File.expand_path "../test_app", __FILE__

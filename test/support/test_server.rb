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

require 'webrick/log'

module WEBrick
  class NullLogger < Log
    def initialize
      @level = 0
    end

    def log(level, data)

    end
  end
end

Thread.new do
  StubServer.new({
    :Port => 7776, 
    :server => :webrick,
    :AccessLog => [],
    :Logger => WEBrick::NullLogger.new
  }).start
end

sleep 1.5

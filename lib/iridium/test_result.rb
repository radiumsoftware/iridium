module Iridium
  class TestResult
    attr_accessor :failed, :error, :passed, :assertions
    attr_accessor :name, :file
    attr_accessor :backtrace, :message
    attr_accessor :time

    def initialize(hash = {}) 
      hash.each_pair do |name, value|
        send "#{name}=", value
      end
    end

    def failed?
      failed
    end

    def error?
      error
    end

    def passed?
      !failed? && !error?
    end
  end
end

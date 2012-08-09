require 'execjs'

module Iridium
  class JSLint
    class Result
      attr_accessor :file

      def initialize(jslint_error)
        @error = jslint_error
      end

      def type
        @error['id'].match(/\((\w+)\)/)[1]
      end

      # Expected '{a}' and instead saw '{b}'.",
      def message
        matches = @error['raw'].scan(/{(\w{1})}/).flatten

        formatted = @error['raw'].dup

        matches.each do |key|
          formatted.gsub! "{#{key}}", @error[key].to_s
        end

        formatted
      end

      def source
        @error['evidence']
      end

      def line
        @error['line']
      end

      def character
        @error['character']
      end
    end

    def self.source
      File.read File.expand_path('../../../vendor/jslint.js', __FILE__)
    end

    def self.context
      @context ||= ExecJS.compile <<-js
        #{source}
        var LINTER = function(source, options) {
          JSLINT(source, options)
          return JSLINT.errors;
        }
      js
    end

    def self.run(content, options = {})
      context.call('LINTER', content).collect { |h| Result.new h }
    end
  end
end

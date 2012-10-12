module Iridium
  module Testing
    class TestCommand < Hydrogen::Command
      description "Executes tests"

      desc "test PATHS", "run tests match by PATHS"
      method_option :debug, :type => :boolean, :default => false
      method_option :dry_run, :type => :boolean, :default => false
      method_option :seed, :type => :numeric
      def test(*paths)
        Iridium.load!

        if paths.size == 0
          paths = Dir['test/**/*_test.{coffee,js}']
        end

        TestSuite.execute paths, options
      end
    end
  end
end

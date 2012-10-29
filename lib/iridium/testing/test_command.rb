module Iridium
  module Testing
    class TestCommand < Hydrogen::Command
      description "Executes tests"

      desc "test PATHS", "run tests match by PATHS"
      method_option :debug, :type => :boolean, :default => false
      method_option :verbose, :type => :boolean, :default => false
      method_option :dry_run, :type => :boolean, :default => false
      method_option :seed, :type => :numeric
      def test(*paths)
        Iridium.load!

        if paths.empty?
          paths = Dir['test/**/*_test.{coffee,js}']
        end

        result = Suite.execute paths, options
        exit result
      end
    end
  end
end

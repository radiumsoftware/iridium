module Iridium
  module Testing
    class TestCommand < Hydrogen::Command
      description "Executes tests"

      desc "test PATHS", "run tests match by PATHS"
      method_option :dry_run, :type => :boolean, :default => false
      method_option :seed, :type => :numeric
      method_option :log_level, :type => :string, :default => 'warn', 
        :banner => 'set to "info" to see console.log statements',
        :desc => <<-desc
          This flag sets the log level. It applies to the internal test runner and
          messages coming out of your test files themselves. 

          It has a few values:

          * debug - Show EVERYTHING. This is like using -vv in many libraries.
          * info  - Show basic logging from the test runner and tests. This will
                    show message printed via "console.log" in your tests.
          * warn  - Print internal failures
      desc

      def test(*paths)
        Iridium.load!

        if paths.empty?
          paths = Dir['test/**/*_test.{coffee,js}']
        end

        result = Suite.execute paths, options
        exit result
      end

      default_task :test
    end
  end
end

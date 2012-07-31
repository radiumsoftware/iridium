module Iridium
  module Commands
    class Test
      class MissingTest < RuntimeError ; end

      class << self
        def start(file_names = ARGV)
          file_names.each do |file|
            $stderr.puts "#{file} does not exist!"
            return 1
          end

          integration_test_files = file_names.select { |f| f =~ %r{test/integration}}
          unit_test_files = file_names = integration_test_files

          tests = [IntegrationTestRunner.new(integration_test_files), UnitTestRunner.new(Iridium.application, unit_test_files)]

          suite = TestSuite.new Iridium.application, tests

          results = suite.run

          puts results.inspect
        end
      end
    end
  end
end

module Iridium
  class JSLintRunner
    class SetupFailed < RuntimeError ; end

    def self.execute(file_names, options = {})
      trap 'INT' do
        puts "Quiting..."
        abort
      end

      file_names = file_names.collect do |path|
        if File.directory? path
          Dir["#{path}/**/*_test.{js,coffee}"]
        else
          path
        end
      end.flatten

      file_names.each do |file|
        if file !~ %r{.js$}
          raise SetupFailed, "#{file} is not Javascript"
        end

        if !File.exists? file
          raise SetupFailed, "#{file} does not exist!"
        end
      end

      report = JSLintReport.new file_names

      results = file_names.collect do |file|
        result = Iridium::JSLint.run File.read(file), options
        result.each { |r| r.file = file }
        report.print result
        result
      end.flatten.compact

      report.print_results results

      return results.empty? ? 0 : 1
    rescue SetupFailed => ex
      $stderr.puts ex
      return 2
    end
  end
end

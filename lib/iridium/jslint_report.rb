module Iridium
  class JSLintReport
    def initialize(files, io = $stdout)
      @files, @io = files, io
    end

    def print(result)
      if result.empty?
        @io.print "."
      else
        @io.print "F"
      end
    end

    def print_results(results)
      summary = "\n\n%d File(s), %d Error(s), %d Warning(s)"

      @io.puts(summary % [
        @files.size, 
        results.select { |r| r.type == 'error' }.size,
        results.select { |r| r.type == 'warning' }.size
      ])

      return if results.empty?

      puts "\n\n\n"

      results.each do |result|
        puts "#{result.type.upcase}: #{result.message}"
        puts "  Source: #{result.source}" 
        puts "  File: #{result.file}:#{result.line}"
        puts "\n"
      end
    end
  end
end

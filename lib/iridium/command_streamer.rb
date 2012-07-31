require 'pty'

module Iridium
  class CommandStreamer
    class CommandFailed < RuntimeError ; end

    def initialize(command)
      @command = command
    end

    def run(options = {})
      PTY.spawn @command do |stdin, stdout, pid|
        stdin.each do |output|
          if output =~ %r{<iridium>(.+)</iridium>}
            yield JSON.parse($1) if block_given?
          elsif options[:debug]
            puts output
          end
        end

        PTY.check pid, true
      end
    rescue PTY::ChildExited => ex
      raise CommandFailed unless ex.status.success?
    rescue Errno::ENOENT => ex
      raise CommandFailed
    end
  end
end

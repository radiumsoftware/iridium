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
      if !ex.status.success?
        raise CommandFailed, "#{@command} returned #{ex.status.exitstatus} when it shouldn't have!"
      end
    rescue Errno::ENOENT => ex
      raise CommandFailed, "#{@command} could not be found!"
    end
  end
end

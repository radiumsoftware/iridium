require 'pty'
require 'json'

module Iridium
  class CommandStreamer
    class CommandFailed < RuntimeError ; end

    def initialize(command)
      @command = command
    end

    def run(options = {})
      PTY.spawn @command do |stdin, stdout, pid|
        stdin.each do |output|
          begin
            if block_given?
              json = JSON.parse output

              if json['iridium']
                yield json['iridium']
              else
                puts output if options[:debug]
              end
            end
          rescue JSON::ParseError
            puts output if options[:debug]
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

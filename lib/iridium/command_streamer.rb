require 'pty'
require 'json'


module Iridium
  class CommandStreamer
    class CommandFailed < RuntimeError ; end
    class ProcessAborted < RuntimeError ; end

    # PTY IO is platform dependent on. Reading raises a Errno:EIO 
    # as regular behavior on some platforms. Wrap it up here so
    # things behave like developers expect
    class SafePTY
      def self.spawn(command, &block)
        PTY.spawn(command) do |r,w,p|
          begin
            yield r,w,p
          rescue Errno::EIO
          end
        end

        $?.exitstatus
      end
    end

    def initialize(command)
      @command = command
    end

    def run(options = {})
      SafePTY.spawn @command do |stdin, stdout, pid|
        stdin.each do |output|
          begin
            if block_given?
              json = JSON.parse output

              if json.is_a?(Hash) && json['iridium']
                yield json['iridium']
              elsif json.is_a?(Hash) && json['abort']
                raise ProcessAborted, json['abort']
              else
                puts output if options[:debug]
              end
            end
          rescue JSON::ParserError
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

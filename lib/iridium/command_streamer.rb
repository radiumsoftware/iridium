require 'pty'
require 'json'

module Iridium
  class CommandStreamer
    class CommandFailed < RuntimeError ; end
    class ProcessAborted < RuntimeError ; end

    def initialize(command)
      @command = command
    end

    def run(options = {})
      PTY.spawn @command do |stdin, stdout, pid|
        trap 'INT' do
          puts "Quiting..."
          abort
        end

        begin
          stdin.each do |output|
            begin
              json = JSON.parse output

              if json.is_a?(Hash) && json['iridium']
                yield json['iridium'] if block_given?
              elsif json.is_a?(Hash) && json['abort']
                raise ProcessAborted, json['abort']
              else
                puts output if options[:debug]
              end
            rescue JSON::ParserError
              puts output if options[:debug]
            end
          end
        rescue Errno::EIO 
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

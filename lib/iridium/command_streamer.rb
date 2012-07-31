require 'pty'

module Iridium
  class CommandStreamer
    def initialize(command)
      @command = command
    end

    def run(options = {})
      raise "Block required!" unless block_given?

      begin
        PTY.spawn @command do |stdin, stdout, pid|
          begin
            stdin.each do |output|
              if output =~ %r{<iridium>(.+)</iridium>}
                yield JSON.parse($1)
              elsif options[:debug]
                puts output
              end
            end
          rescue Errno::EIO
          end
        end
      rescue PTY::ChildExited
      end
    end
  end
end

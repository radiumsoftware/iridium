require 'iridium/commands/application'
require 'thor/group'

module Iridium
  class CLI < Thor
    subcommand Commands::Application, :new
  end
end

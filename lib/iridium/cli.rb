require 'iridium/commands/application'
require 'thor/group'

module Iridium
  class CLI < Thor
    register Commands::Application, :new, "new", "Run the application generator"
  end
end

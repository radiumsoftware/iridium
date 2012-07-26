require 'iridium/commands/application'
require 'thor/group'

module Iridium
  class CLI < Thor
    register Commands::Application, :new, "new PATH", "generate a new pipeline in PATH"
  end
end

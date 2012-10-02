require "hydrogen/version"

require "ostruct"

require "thor"

require "hydrogen/path_set"

require "hydrogen/command"
require "hydrogen/component"
require "hydrogen/cli"

require "hydrogen/application"

module Hydrogen
  class Error < StandardError ; end
  class IncorrectRoot < Error ; end

  # Your code goes here...
end

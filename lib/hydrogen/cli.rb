module Hydrogen
  class CLI < Thor
    class << self
      def inherited(base)
        Component.loaded.each do |component|
          component.commands.each do |hash|
            command_class, command_name = hash[:class], hash[:name]
            base.desc "#{command_name} command ARGS", command_class.description_banner
            base.subcommand command_name.to_s, command_class
          end
        end
      end
    end
  end
end

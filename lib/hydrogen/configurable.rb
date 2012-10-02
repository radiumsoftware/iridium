module Hydrogen
  module Configurable
    def config
      instance.config
    end

    def command(klass, name)
      commands << { :klass => klass, :name => name }
    end

    def commands
      config.commands
    end

    def instance
      @instance ||= new
    end
  end
end

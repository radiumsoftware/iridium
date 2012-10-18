module Iridium
  class Application < Engine
    class << self
      def inherited(base)
        raise "You cannot have more than one Iridium::Application" if Iridium.application
        super
        Iridium.application = base.instance
      end
    end

    initializer do |app|
      begin
        require "#{app.root}/config/application.rb"
      rescue LoadError ; end
    end

    initializer do |app|
      begin
        require "#{app.root}/config/#{Iridium.env}.rb"
      rescue LoadError
      end
    end

    def root
      @root ||= find_root_with_flag("application.rb", Dir.pwd)
    end

    def boot!
      raise "root is not set. You must set the root directory before using!" unless root

      settings_hash = paths[:settings].expanded.inject({}) do |hash, file|
        values = YAML.load(ERB.new(File.read(file)).result)[Iridium.env]
        hash.merge values
      end

      config.settings = OpenStruct.new settings_hash

      run_callbacks :initialize, self
    end

    def settings
      config.settings
    end

    private
    def run_callbacks(name, *args)
      return unless callbacks[name]

      callbacks[name].invoke *args
    end
  end
end

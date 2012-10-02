module Hydrogen
  module Configurable
    def config
      instance.config
    end

    def instance
      @instance ||= new
    end
  end
end

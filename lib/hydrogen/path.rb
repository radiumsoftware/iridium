module Hydrogen
  class Path
    def initialize(root)
      @root = root
      @map = {}
    end

    def rake
      @map[:rake]
    end

    def vendor
      @map[:vendor]
    end
  end
end

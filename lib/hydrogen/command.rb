module Hydrogen
  class Command < Thor
    class << self
      def description(banner)
        @description = banner
      end

      def description_banner
        @description
      end
    end
  end
end

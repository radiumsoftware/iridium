module Iridium
  module Pipeline
    class PrependEnvironmentFilter < ::Rake::Pipeline::Filters::PrependFilter
      def prepend
        str = <<-js
        var Iridium = {};
        Iridium.env = '#{Iridium.env}';
        window.Iridium = Iridium;
        js
      end
    end
  end
end

module Iridium
  class AssetPipeline < Rake::Pipeline::Project
    class DSL < Rake::Pipeline::DSL::ProjectDSL
      def app
        raise "Cannot use the Iridium specific pipeline without declaring an application!" unless Iridium.application
        Iridium.application
      end
    end

    def build(&block)
      DSL.evaluate(self, &block) if block
      self
    end
  end
end

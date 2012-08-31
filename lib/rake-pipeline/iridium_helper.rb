module Rake
  class Pipeline
    module IridiumHelper
      def app
        raise "Cannot use the Iridium specific pipeline without declaring an application!" unless Iridium.application
        Iridium.application
      end

      def inject(glob, &block)
        matcher = pipeline.copy Rake::Pipeline::InjectionMatcher, &block
        matcher.glob = glob
        pipeline.add_filter matcher
        matcher
      end
    end
  end
end

module Rake
  class Pipeline
    module DSL
      class PipelineDSL
        include IridiumHelper
      end

      class ProjectDSL
        include IridiumHelper
      end
    end
  end
end

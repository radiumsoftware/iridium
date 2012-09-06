module Rake
  class Pipeline
    module IridiumHelper
      def app
        raise "Cannot use the Iridium specific pipeline without declaring an application!" unless Iridium.application
        Iridium.application
      end
    end
  end
end

module Rake
  class Pipeline
    module DSL
      class PipelineDSL
        include IridiumHelper

        def drop(pattern)
          matcher = pipeline.copy(DropMatcher)
          matcher.glob = pattern
          pipeline.add_filter matcher
          matcher
        end
        alias :skip :drop
      end

      class ProjectDSL
        include IridiumHelper
      end
    end
  end
end

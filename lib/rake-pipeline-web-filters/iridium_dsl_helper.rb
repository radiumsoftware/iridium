module AppPipelineHelper
  def app
    raise "Cannot use the Iridium specific pipeline without declaring an application!" unless Iridium.application
    Iridium.application
  end
end

module Rake
  class Pipeline
    module DSL
      class PipelineDSL
        include AppPipelineHelper
      end

      class ProjectDSL
        include AppPipelineHelper
      end
    end
  end
end

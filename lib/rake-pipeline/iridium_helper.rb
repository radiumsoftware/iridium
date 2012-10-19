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
    class Matcher
      include IridiumHelper
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

        def sort(&block)
          sorter = pipeline.copy(SortedPipeline)
          sorter.sorter = block
          pipeline.add_filter sorter
          sorter
        end

        def engines_first
          sort do |f1, f2|
            in_engine = lambda do |file|
              engines = Iridium::Engine.subclasses
              engines.delete pipeline.app.class
              engines.any? do |engine|
                file.fullpath.include? engine.instance.root.to_s
              end
            end

            if in_engine.call(f1) && !in_engine.call(f2)
              -1
            elsif in_engine.call(f2) && !in_engine.call(f1)
              1
            else
              0
            end
          end
        end
      end

      class ProjectDSL
        include IridiumHelper
      end
    end
  end
end

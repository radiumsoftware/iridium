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

        def app_overrides_engines
          # Skip files that exist in engines and app. App javascripts
          # should take precendence over the same file in engines
          skip do |input|
            app_vendor_files = app.paths[:vendor].expanded.collect do |path|
              Dir["#{path}/**/*"].collect do |file|
                File.basename file
              end
            end.flatten

            engine_vendor_files = app.engine_paths[:vendor].expanded.collect do |path|
              Dir["#{path}/**/*"]
            end.flatten

            file_name = File.basename input.path

            app_vendor_files.include?(file_name) && engine_vendor_files.include?(input.fullpath)
          end
        end
      end

      class ProjectDSL
        include IridiumHelper
      end
    end
  end
end

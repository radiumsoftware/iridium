module Rake::Pipeline::Web::Filters
  class ManifestFilter < Rake::Pipeline::Filter
    include Rake::Pipeline::Web::Filters::FilterWithDependencies

    def initialize(name = 'cache.manifest', &asset_name)
      @asset_name = asset_name
      block = proc { |input| name }
      super(&block)
    end

    def generate_output(inputs, output)
      assets = inputs.collect do |i| 
        path = i.path.gsub('manifest/', '')

        if @asset_name
          @asset_name.call path
        else
          path
        end

      end.join("\n")

      output.write ERB.new(template).result(binding)
    end

    def external_dependencies
      [ "erb" ]
    end

    def template
      <<-erb
CACHE MANIFEST

# Tag: <%= Time.now.to_i %>

CACHE:
<%= assets %>

NETWORK:
# All other resources require network access
*
      erb
    end
  end

  module PipelineHelpers
    def cache_manifest(*args, &block)
      match "**/*" do
        copy { |name| [name, "manifest/#{name}"] }
      end

      match "manifest/**/*" do
        filter(Rake::Pipeline::Web::Filters::ManifestFilter, *args, &block)
      end
    end
  end
end

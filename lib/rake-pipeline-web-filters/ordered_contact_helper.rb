module Rake::Pipeline::Web::Filters
  module PipelineHelpers
    def ordered_concat(*args, &block)
      filter(Rake::Pipeline::OrderingConcatFilter, *args, &block)
    end
  end
end

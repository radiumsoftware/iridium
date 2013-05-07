require 'grit'

module Iridium
  module Pipeline
    class FinalizingFilter < Rake::Pipeline::Filters::PrependFilter
      def initialize(root)
        @root = root
        super()
      end

      def prepend
        begin
<<-header
  // Build Time: #{Time.now}
  // SHA: #{head.id}
  // Commit Date: #{head.committed_date}
  // Author: #{head.author}

header
        rescue Grit::InvalidGitRepositoryError
          "// Build Time: #{Time.now}\n"
        end
      end

      def repo
        @repo ||= Grit::Repo.new @root
      end

      def head
        @head ||= repo.commits.first
      end
    end
  end
end

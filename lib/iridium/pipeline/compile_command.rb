module Iridium
  module Pipeline
    class CompileCommand < Hydrogen::Command
      description "Compile assets for deployment"

      desc "compile", "compile assets for deployment"
      method_option :environment, :aliases => '-e', :default => 'production'
      def compile
        ENV['IRIDIUM_ENV'] = options[:environment]
        Iridium.load!
        Iridium.application.compile
      end

      default_task :compile
    end
  end
end

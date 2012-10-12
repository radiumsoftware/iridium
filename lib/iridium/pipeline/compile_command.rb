module Iridium
  module Pipeline
    class CompileCommand < Hydrogen::Command
      description "Compile assets for deployment"

      desc "compile PATH", "compile assets for deployment to an optional PATH"
      method_option :environment, :aliases => '-e', :default => 'production'
      def compile(path = nil)
        ENV['IRIDIUM_ENV'] = options[:environment]

        Iridium.load!

        if path
          raise "#{path} does not exist!" unless File.directory? path
          Iridium.application.site_path = Pathname.new path
        end

        Iridium.application.compile
      end
    end
  end
end

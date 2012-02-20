require "frontend_server/version"

require 'erb'
require 'yaml'
require 'rack/reverse_proxy'
require 'rack/rewrite'
require 'rake-pipeline'
require 'rake-pipeline/middleware'
require 'rake-pipeline-web-filters'

module FrontendServer
  class AddHeader
    def initialize(app, header, value)
      @app, @header, @value = app, header, value
    end

    def call(env)
      env[header_name] = @value
      @app.call env
    end

    private
    def header_name
      rack_header = @header.gsub /^HTTP_/, ''
      rack_header.gsub('_', '-')
      "HTTP_#{rack_header}".upcase
    end
  end

  class PipelineReloader
    IGNORED_REQUESTS = [/^\/api/, /favicon\.ico/]

    def initialize(app, server)
      @app, @server = app, server
    end

    def call(env)
      @server.reset! unless skip? env

      @app.call env
    end

    def skip?(env)
      !IGNORED_REQUESTS.select {|r| env['PATH_INFO'] =~ r }.empty?
    end
  end

  class Application
    attr_accessor :root
    attr_reader :config

    class << self
      def configure(&block)
        @callbacks ||= []
        @callbacks << block
      end

      def configurations
        @callbacks || []
      end

      def root=(val)
        @root = val
      end

      def root
        @root
      end
    end

    def env
      ENV['RACK_ENV'] || 'development'
    end

    def boot!
      @config = OpenStruct.new(YAML.load(ERB.new(File.read("#{root}/config/application.yml")).result)[env])


      begin
        require "#{root}/config/environment.rb"

        # Now require the individual enviroment files
        # that can be used to add middleware and all the
        # other standard rack stuff
        require "#{root}/config/#{env}.rb"
      rescue LoadError
      end
    end

    def root
      self.class.root
    end

    def app
      boot!

      server = self

      builder = Rack::Builder.new

      builder.use Rack::Rewrite do
       rewrite '/', '/index.html'
      end

      self.class.configurations.each do |configuration|
        configuration.call builder, config
      end

      if development?
        builder.use FrontendServer::PipelineReloader, server
        builder.use Rake::Pipeline::Middleware, pipeline
      end

      builder.use Rack::ReverseProxy do
        reverse_proxy /^\/api(\/.*)$/, "#{server.config.server}$1"
      end

      if production?
        builder.use Rack::ETag
        builder.use Rack::ConditionalGet
      end

      builder.run Rack::Directory.new 'public'

      builder.to_app
    end

    def production?
      env == 'production'
    end

    def development?
      env == 'development'
    end

    def reset!
      project.cleanup_tmpdir
      project.clean
    end

    def pipeline
      server = self

      Rake::Pipeline.build do
        output "#{server.root}/public"
        input "#{server.root}/app"

        match "**/*.handlebars" do
          handlebars
        end

        match "**/*.coffee" do
          coffee_script
        end

        match "{javascripts,vendor/javascripts}/**/*.js" do
          minispade :module_id_generator => proc { |input|
            if input.path =~ /vendor/
              File.basename input.path, '.js'
            else
              input.path.gsub(/javascripts\//, "#{server.module_name}/").gsub(/\.js$/, '')
            end
          }

          uglify if server.production?

          concat "application.js"
        end

        match "**/*.{css,scss}" do
          sass

          yui_css if server.production?

          concat "application.css"
        end

        match "public/**/*" do
          copy do |input|
            input.sub(/public\//, '')
          end
        end

        match "images/**/*" do
          copy
        end
      end
    end

    def project
      Rake::Pipeline::Project.new pipeline
    end

    def module_name
      self.class.to_s.split("::").last.downcase
    end

    def call(env)
      app.call(env)
    end
  end
end

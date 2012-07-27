module Iridium
  class TestSuite
    attr_accessor :unit_tests, :integration_tests
    attr_reader :app, :files

    def initialize(app, files, seed = nil)
      @app, @files = app, files
      @files = @files.collect do |file|
        file.to_s.gsub app.root.to_s, ''
      end
    end

    def integration_tests
      files.select { |f| f =~ /test\/integration\// }
    end

    def unit_tests
      files - integration_tests
    end

    def runners
      _runners = []
      _runners = unit_tests.each_with_object(_runners) do |file, memo|
        memo << UnitTestRunner.new(app, file)
      end
      _runners = integration_tests.each_with_object(_runners) do |file, memo|
        memo << IntegrationTestRunner.new(app, file)
      end
      _runners
    end

    def run
      setup
      teardown
    end

    private
    def server_thread
      @server_thread
    end

    def integration_tests?
      integration_tests.size > 0
    end

    def unit_tests?
      unit_tests.size > 0
    end

    def setup
      app.compile
      build_unit_test_directory if unit_tests?
      start_server if integration_tests?
    end

    def teardown
      kill_server if integration_tests?
    end

    def build_unit_test_directory
      _pipeline = Rake::Pipeline.build do
        input app.root
        output app.root.join('tmp', 'unit_tests')

        match 'test/**/*.coffee' do
          coffee_script
        end

        match 'test/**/*_test.js' do
          copy
        end

        match "test/support/**/*.js" do
          copy
        end

        site_directory = File.basename(app.site_path)

        match "#{site_directory}/**/*" do
          copy do |path|
            path.sub(%r{^#{site_directory}\/}, '')
          end
        end
      end

      _pipeline.tmpdir = app.root.join('tmp', 'unit_test_pipeline')
      _pipeline.invoke_clean
    end

    def start_server
      @server_thread = Thread.new do
        puts "Starting test server..."
        Rack::Server.new(:app => Iridium.application).start
      end
    end

    def kill_server
      Thread.kill server_thread
    end
  end
end

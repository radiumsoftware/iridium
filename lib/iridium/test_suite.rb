require 'rack/server'
require 'coffee-script'

module Iridium
  # Iridium supports two types of tests right out of the box
  #
  # 1. Integration Tests: These need a running Iridium::Application server
  # 2. Unit Tests: These tests don't need a running app server
  #
  # The tests are meant to be run with the $ iridium test PATH
  # command. 
  #
  # Examples:
  # $ iridium test test/**/*_test.*
  # $ iridium test test/integration/login_test.js
  # $ iridium test test/unit/validation_test.coffee
  #
  # Tests can be written either Coffeescript or Javascript.
  # Iridium handles the compilation from CS to JS for you
  # seamlessly. 
  #
  # == Behind the Scenes ==
  #
  # There are many different things that must happen for all this work
  # for the developer. Starting from the beginning, all coffeescript files
  # need to be compiled into javascript. This yields a directory tree of
  # javascript files. The application itself must be compiled so all the
  # assets available to the different test runners. Once we have all the 
  # javascript files and assets we can proceed to running tests.
  #
  # === Running Unit Tests ===
  #
  # The test process is different for integration tests and unit tests.
  # Unit tests are written for qUnit. Running qUnit test requires a HTML
  # file to load in qunit.js, qunit.css, all the application assets, and 
  # all the the test files. Running a unit test consists of:
  #
  # 1. Generating the proper HTML file to load everything
  # 2. Create a casperjs browser to navigate to that file
  # 3. Use casperjs to scrape the results
  # 4. Report the results
  #
  # === Running Integration Tests ===
  #
  # Integration tests are slightly less complicated. Running an integration
  # test consists of:
  #
  # 1. Start an Iridium::Application server
  # 2. Boot and point casperjs to the running server
  # 3. Casperjs executes the test
  # 4. Shutdown casper
  # 5. Shutdown the test server
  # 6. Report results
  class TestSuite
    class SetupFailed < RuntimeError ; end

    def self.execute(file_names, options = {})
      raise SetupFailed, "No application loaded!" unless Iridium.application

      trap 'INT' do
        puts "Quiting..."
        abort
      end

      file_names = file_names.collect do |path|
        if File.directory? path
          Dir["#{path}/**/*_test.{js,coffee}"]
        else
          path
        end
      end.flatten

      raise SetupFailed, "Could not find any test files!" if file_names.empty?

      file_names.each do |file|
        if file !~ %r{.(coffee|js)}
          raise SetupFailed, "#{file} is not Javascript or Coffeescript"
        end

        if !File.exists? file
          raise SetupFailed, "#{file} does not exist!"
        end
      end

      if Dir[Iridium.application.root.join('test/helper.{js,coffee}')].empty?
        raise SetupFailed, "You could not find test/helper.js or test/helper.coffee"
      end

      files_to_check = file_names.select { |f| f =~ %r{.coffee$} }
      files_to_check += Dir[Iridium.application.root.join('test', 'support', '**', '*.coffee')]
      files_to_check += Dir[Iridium.application.root.join('test', 'helper.coffee')]

      files_to_check.each do |file|
        begin
          CoffeeScript.compile File.read(file)
        rescue ExecJS::ProgramError => ex
          raise SetupFailed, "Could not compile #{file}: #{ex}"
        end
      end

      report = TestReport.new

      options[:seed] ||= srand % 0xFFFF
      srand options[:seed]

      file_names.shuffle!

      tests = [TestRunner.new(Iridium.application, file_names, report.collector)]

      suite = TestSuite.new Iridium.application, tests

      results = suite.run options

      report.print_results results

      if results.all?(&:passed?) || options[:dry_run]
        return 0
      else
        return 1
      end
    rescue CommandStreamer::ProcessAborted => ex
      $stderr.puts ex
      return 2
    rescue SetupFailed => ex
      $stderr.puts ex
      return 2
    end

    def initialize(app, tests = [])
      @app, @tests, = app, tests
      @results = []
    end

    def run(options = {})
      setup

      puts "Run options: #{options.keys.collect {|k| "--#{k.to_s.dasherize} #{options[k]}" }.join(" ")}"
      puts "\n"
      puts "# Running Tests:\n\n"

      @results = @tests.map { |t| t.run(options) }.flatten
    ensure
      teardown
      @results
    end

    def test_root
      @app.root.join('tmp', 'test_root')
    end

    private
    def setup
      @app.compile
      start_server
      create_unit_test_loader
      @results.clear
    rescue ExecJS::ProgramError => ex
      raise SetupFailed, ex.to_s
    end

    def teardown
      delete_unit_test_loader
      kill_server
    end

    def create_unit_test_loader
      File.open loader_path, "w+" do |index|
        index.puts ERB.new(template_erb).result(binding)
      end
    end

    def delete_unit_test_loader
      FileUtils.rm loader_path if File.exists? loader_path
    end

    def loader_path
      @app.site_path.join "unit_test_runner.html"
    end

    def template_erb
      template_path = @app.root.join('test', 'support', 'unit_test_runner.html.erb')

      if File.exists? template_path
        File.read template_path
      else
        default_template
      end
    end

    def default_template
      <<-str
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Unit Tests</title>

          <!--[if lt IE 9]>
            <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
          <![endif]-->
        </head>

        <body>
          <% @app.config.dependencies.each do |script| %>
            <script src="<%= script.url %>"></script>
          <% end %>

          <script src="application.js"></script>

          <script type="text/javascript">
            minispade.require('<%= @app.class.to_s.underscore %>/app');
          </script>
        </body>
      </html>
      str
    end

    def start_server
      @server = Thread.new do
        begin
          Thin::Logging.silent = true

          ::Rack::Server.new({
            :app => @app, 
            :Port => 7777,
            :server => :thin
          }).start
        rescue
          return
        end
      end

      sleep 0.5 # give the thread some time to boot

      raise SetupFailed, "Server failed to start!" unless @server.alive?
    end

    def kill_server
      if @server
        @server.kill
        sleep 0.5
        raise "Server failed to die!" if @server.alive?
      end
    end
  end
end

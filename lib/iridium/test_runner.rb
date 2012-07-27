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
  class TestRunner
    attr_reader :app

    def initialize(app)
      @app = app
    end
  end

  # This class runs a set of unit tests and reports their results.
  # It is responsible for generating a test loader (HTML) file
  # to load the test framework, application assets, and test classes.
  # Once that is ready, it loads that file using caspserjs and scrapes
  # the results and reports them.
  class UnitTestRunner
    attr_reader :app

    def pipline
    end

    def test_directory_path
      app.root.join('tmp', 'unit_tests')
    end

    def loader_path(test_run_id = Time.now.to_i)
      app.root.join "unit_test_runs", "#{test_run_id}_loader.html"
    end

    def template
      template_path = app.root.join('test', 'unit', 'runner.html.erb')

      if File.exists?
        File.read template_path
      else
        default_template
      end
    end

    def framework
      app.config.test_framework
    end

    def framework_path
      app.root.join "test", "frameworks", "unit", framework
    end

    def framework_javascripts
      Dir[framework_path.join "*.js"].collect do |file|
        File.basename file
      end
    end

    def framework_stylesheets
      Dir[framework_path.join "*.css"].collect do |file|
        File.basename file
      end
    end

    private
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

          <link href="/application.css" rel="stylesheet">
        </head>

        <body>
          <% iridium.config.dependencies.each do |script| %>
            <script src="<%= script.url %>"></script>
          <% end %>

          <% test_files.each do |file| %>
            <script src="<%= file %>"></script>
          <% end %>

          <script src="/application.js"></script>
        </body>
      </html>
      str
    end
  end
end

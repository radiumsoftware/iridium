require 'test_helper'

class RunningTestsTest < MiniTest::Unit::TestCase
  def index_file_content
    ERB.new(File.read(INDEX_FILE_PATH)).result(binding)
  end

  # For the template
  def camelized
    Iridium.application.class.to_s.camelize
  end

  def underscored
    Iridium.application.class.to_s.underscore
  end

  def setup
    super

    Iridium.application.config.dependencies.load :minispade

    create_file "app/javascripts/boot.js", <<-file
      require('test_app/app');
      window.AppBooted = true;
    file

    create_file "app/javascripts/app.js", <<-file
      window.TestApp = true;
      window.AppLoaded = true;
    file

    File.open Iridium.application.vendor_path.join("javascripts", "minispade.js"), "w" do |file|
      file.puts File.read(Iridium.vendor_path.join("minispade.js"))
    end

    create_file "app/assets/index.html.erb", index_file_content
  end

  def working_directory
    Iridium.application.root
  end

  def test_raises_an_error_if_file_does_not_exist
    status, stdout, stderr = invoke "foo.js"

    assert_equal 2, status, "Tests should fail! #{stdout}"
    assert_includes stderr, "foo.js"
  end

  def test_runs_a_unit_test_in_javascript
    create_file "test/unit/truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    status, stdout, stderr = invoke "test/unit/truth_test.js"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "1 Test(s)"
  end

  def test_runs_an_integration_test
    create_file "test/integration/truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    status, stdout, stderr = invoke "test/integration/truth_test.js"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "1 Test(s)"
  end

  def test_pukes_on_invalid_coffee_script_tests
    create_file "test/unit/invalid_coffeescript.coffee", <<-test
      test 'Truth' ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit/invalid_coffeescript.coffee"

    assert_equal 2, status, "Tests should fail! #{stdout}"
    assert_includes stderr, "test/unit/invalid_coffeescript.coffee"
    assert_includes stderr, "error"
  end

  def test_pukes_on_invalid_coffee_script_in_support_files
    create_file "test/support/error.coffee", <<-test
      thisMethod(), ->
    test

    create_file "test/unit/truth_test.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit/truth_test.coffee"

    assert_equal 2, status, "Tests should fail! #{stdout}"
    assert_includes stderr, "test/support/error.coffee"
    assert_includes stderr, "error"
  end

  def test_runs_coffee_script_unit_test
    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit/truth.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "1 Test(s)"
  end

  def test_runs_coffee_script_integration_test
    create_file "test/integration/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/integration/truth.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "1 Test(s)"
  end

  def test_runs_unit_and_integration_tests
    create_file "test/integration/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/integration/truth.coffee", "test/integration/truth.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "2 Test(s)"
  end

  def test_broken_integration_tests_dont_stop_unit_tests
    create_file "test/integration/error.coffee", <<-test
      foobar()
    test

    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/integration/error.coffee", "test/unit/truth.coffee"

    assert_equal 1, status, "Tests should fail! #{stdout}"
  end

  def test_broken_unit_tests_dont_stop_integration_tests
    create_file "test/integration/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    create_file "test/unit/error.coffee", <<-test
      foobar()
    test

    status, stdout, stderr = invoke "test/unit/error.coffee", "test/integration/truth.coffee"

    assert_equal 1, status, "Tests should fail! #{stdout}"
  end

  def test_console_logging_goes_to_stdout
    create_file "test/integration/logging.coffee", <<-test
      test 'Truth', ->
        expect(0)
        console.log 'integration logging'
    test

    create_file "test/unit/logging.coffee", <<-test
      test 'Truth', ->
        expect(0)
        console.log 'unit logging'
    test

    status, stdout, stderr = invoke "test/unit/logging.coffee", "test/integration/logging.coffee", :log_level => 'info'

    assert_includes stdout, "integration logging"
    assert_includes stdout, "unit logging"
  end

  def test_runner_returns_successfully_on_dry_run
    create_file "test/integration/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "passed!"
    test

    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/integration/truth.coffee", "test/integration/truth.coffee", :dry_run => true

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "0 Test(s)"
  end

  def test_runner_pukes_if_passing_a_non_js_or_cs_file
    create_file "test/unit/truth_test.rb", <<-test
      :D
    test

    status, stdout, stderr = invoke "test/unit/truth_test.rb"

    assert_equal 2, status, "Tests should fail: #{stdout}"
    assert_includes stderr, "test/unit/truth_test.rb"
  end

  def test_runner_parses_directories
    create_file "test/unit/truth_test.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
  end

  def test_app_module_is_loaded_in_unit_tests
    create_file "test/app_test.coffee", <<-test
      test 'minispade modules are required', ->
        ok window.AppLoaded, "test_app/app should be required!"
    test

    status, stdout, stderr = invoke "test/app_test.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
  end

  def test_boot_module_is_loaded_in_integration_tests
    create_file "test/integration/boot_test.coffee", <<-test
      test "app is booted", ->
        ok window.AppBooted, "App should be booted!"
    test

    status, stdout, stderr = invoke "test/integration/boot_test.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
  end

  def test_uses_custom_unit_test_loader
    create_file "test/unit_test_runner.html", <<-html
      <!DOCTYPE html>
      <html lang="en">
        <body>
          <script type="text/javascript">
            window.MyLoader = true;
          </script>
        </body>
      </html>
    html

    create_file "test/runner_test.coffee", <<-test
      test 'minispade modules are required', ->
        ok window.MyLoader, "correct unit test loader was not used!"
    test

    status, stdout, stderr = invoke "test/runner_test.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
  end

  def test_uses_custom_unit_test_loader_in_erb
    create_file "test/unit_test_runner.html.erb", <<-html
      <!DOCTYPE html>
      <html lang="en">
        <body>
          <script type="text/javascript">
            window.MyLoader = true;
          </script>
        </body>
      </html>
    html

    create_file "test/runner_test.coffee", <<-test
      test 'minispade modules are required', ->
        ok window.MyLoader, "correct unit test loader was not used!"
    test

    status, stdout, stderr = invoke "test/runner_test.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
  end

  def test_app_code_is_directly_accessible_in_integration_tests
    create_file "test/integration/code_access_test.coffee", <<-test
      test "can access the app", ->
        ok window.TestApp, "TestApp should be accessible!"
    test

    status, stdout, stderr = invoke "test/integration/code_access_test.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stdout}"
  end

  def test_failing_integration_test_does_not_stop_other_integration_tests
    create_file "test/integration/failing_test.coffee", <<-test
      test "one test is ran", ->
        ok false, "This should fail!"
    test

    create_file "test/integration/truth_test.coffee", <<-test
      test "another test is ran", ->
        ok true, "This passes!"
    test

    status, stdout, stderr = invoke "test/integration/failing_test.coffee", "test/integration/truth_test.coffee"

    assert_equal 1, status, "Test should fail! Output:\n #{stdout}"
    assert_includes stdout, "2 Test(s)"
    assert_includes stdout, "2 Assertion(s)"
  end

  def tests_support_files_are_included
    create_file "test/support/helper.coffee", <<-helper
      window.supportFileLoaded = true
    helper

    create_file "test/unit/support_test.js", <<-test
      test('support files are loaded', function() {
        ok(window.supportFileLoaded, "Support files not loaded!");
      });
    test

    create_file "test/integration/support_test.js", <<-test
      test('support files are loaded', function() {
        ok(window.supportFileLoaded, "Support files not loaded!");
      });
    test

    status, stdout, stderr = invoke "test/unit/support_test.js", "test/integration/support_test.js"

    assert_equal 0, status
  end

  def tests_support_files_contain_valid_coffee_script
    create_file "test/support/helper.coffee", <<-helper
     ->(;
    helper

    create_file "test/unit/support_test.js", <<-test
      test('support files are loaded', function() {
        ok(window.supportFileLoaded, "Support files not loaded!");
      });
    test

    create_file "test/integration/support_test.js", <<-test
      test('support files are loaded', function() {
        ok(window.supportFileLoaded, "Support files not loaded!");
      });
    test

    status, stdout, stderr = invoke "test/unit/support_test.js", "test/integration/support_test.js"

    assert_equal 2, status
    assert_includes stderr, "test/support/helper.coffee"
  end

  def invoke(*paths)
    stdout, stderr, status = nil

    stdout, stderr = capture_io do
      Dir.chdir Iridium.application.root do
        options = paths.extract_options!
        status = Iridium::Testing::Suite.execute paths, options
      end
    end

    return status, stdout, stderr
  end
end

require 'test_helper'
require 'iridium/commands/test'

class RunningTestsTest < MiniTest::Unit::TestCase
  def setup
    Iridium.application = TestApp.instance
    Iridium.application.config.dependencies.clear
    Iridium.application.config.load :minispade

    create_file "app/javascripts/app.js", <<-file
      window.IridiumBooted = true;
    file

    FileUtils.mkdir_p Iridium.application.root.join "test", "support"

    File.open Iridium.application.root.join('test', 'support', 'qunit.js'), "w" do |qunit|
      qunit.puts File.read(File.expand_path("../../fixtures/qunit.js", __FILE__))
    end

    FileUtils.mkdir_p Iridium.application.root.join "app", "dependencies"

    File.open Iridium.application.root.join("app", "dependencies", "minispade.js"), "w" do |file|
      file.puts File.read(File.expand_path('../../fixtures/minispade.js', __FILE__))
    end
  end

  def teardown
    Iridium.application.config.dependencies.clear
    FileUtils.rm_rf Iridium.application.root.join("app")
    FileUtils.rm_rf Iridium.application.root.join("site")
    FileUtils.rm_rf Iridium.application.root.join("tmp")
    FileUtils.rm_rf Iridium.application.root.join("test")
    Iridium.application = nil
  end

  def working_directory
    Iridium.application.root
  end

  def test_helper
    <<-str
      class Helper
        scripts: [
          'support/qunit'
          'iridium/qunit_adapter'
        ]

        iridium: ->
          _iridium = requireExternal('iridium').create()
          _iridium.scripts = @scripts
          _iridium

      exports.casper = (options) ->
        (new Helper).iridium().casper(options)
    str
  end

  def test_raises_an_error_if_file_does_not_exist
    status, stdout, stderr = invoke "foo.js"

    assert_equal 2, status
    assert_includes stderr, "foo.js"
  end

  def test_raise_an_error_if_there_is_no_test_helper
    create_file "test/unit/truth_test.js", <<-test
      var foo = {}
    test

    status, stdout, stderr = invoke "test/unit/truth_test.js"

    assert_equal 2, status
    assert_includes stderr, "test/helper"
  end

  def test_runs_a_unit_test_in_javascript
    create_file "test/helper.coffee", test_helper

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
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/truth_test.js", <<-test
      casper.start('http://localhost:7777/', function() {
        this.test.assertHttpStatus(200, 'Server should be up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    status, stdout, stderr = invoke "test/integration/truth_test.js"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "1 Test(s)"
  end

  def test_pukes_on_invalid_coffee_script
    create_file "test/helper.coffee", test_helper

    create_file "test/unit/invalid_coffeescript.coffee", <<-test
      test 'Truth' ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit/invalid_coffeescript.coffee"

    assert_equal 2, status
    assert_includes stderr, "test/unit/invalid_coffeescript.coffee"
    assert_includes stderr, "compiling"
  end

  def test_runs_coffee_script_unit_test
    create_file "test/helper.coffee", test_helper

    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit/truth.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "1 Test(s)"
  end

  def test_runs_coffee_script_integration_test
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/truth.coffee", <<-test
      casper.start 'http://localhost:7777/', ->
        this.test.assertHttpStatus(200, 'Server should be up')

      casper.run ->
        this.test.done()
    test

    status, stdout, stderr = invoke "test/integration/truth.coffee"

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "1 Test(s)"
  end

  def test_runs_unit_and_integration_tests
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/truth.coffee", <<-test
      casper.start 'http://localhost:7777/', ->
        this.test.assertHttpStatus(200, 'Server should be up')

      casper.run ->
        this.test.done()
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
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/error.coffee", <<-test
      foobar()
    test

    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/integration/error.coffee", "test/unit/truth.coffee"

    assert_equal 1, status
  end

  def test_broken_unit_tests_dont_stop_integration_tests
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/truth.coffee", <<-test
      casper.start 'http://localhost:7777/', ->
        this.test.assertHttpStatus(200, 'Server should be up')

      casper.run ->
        this.test.done()
    test

    create_file "test/unit/error.coffee", <<-test
      foobar()
    test

    status, stdout, stderr = invoke "test/unit/error.coffee", "test/integration/truth.coffee"

    assert_equal 1, status
  end

  def test_runner_supports_debug_mode
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/logging.coffee", <<-test
      console.log 'integration logging'

      casper.exit()
    test

    create_file "test/unit/logging.coffee", <<-test
      console.log 'unit logging'
    test

    status, stdout, stderr = invoke "test/unit/logging.coffee", "test/integration/logging.coffee", "--debug"

    assert_includes stdout, "integration logging"
    assert_includes stdout, "unit logging"
  end

  def test_runner_returns_successfully_on_dry_run
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/truth.coffee", <<-test
      casper.start 'http://localhost:7777/', ->
        this.test.assertHttpStatus(200, 'Server should be up')

      casper.run ->
        this.test.done()
    test

    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/integration/truth.coffee", "test/integration/truth.coffee", "--dry-run"

    assert_equal 0, status
    assert_includes stdout, "0 Test(s)"
  end

  def test_runner_defaults_to_all_test_files_when_no_arguments
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/truth_test.coffee", <<-test
      casper.start 'http://localhost:7777/', ->
        this.test.assertHttpStatus(200, 'Server should be up')

      casper.run ->
        this.test.done()
    test

    create_file "test/unit/truth_test.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke

    assert_equal 0, status, "Test should pass! Output:\n #{stderr}"
    assert_includes stdout, "2 Test(s)"
  end

  def test_runner_pukes_if_passing_a_non_js_or_cs_file
    create_file "test/helper.coffee", test_helper

    create_file "test/unit/truth_test.rb", <<-test
      :D
    test

    status, stdout, stderr = invoke "test/unit/truth_test.rb"

    assert_equal 2, status
    assert_includes stderr, "test/unit/truth_test.rb"
  end

  def invoke(*args)
    stdout, stderr, status = nil

    stdout, stderr = capture_io do
      Dir.chdir Iridium.application.root do
        status = Iridium::Commands::Test.start(args)
      end
    end

    return status, stdout, stderr
  end

  private
  def create_file(path, content)
    full_path = Iridium.application.root.join path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end
end

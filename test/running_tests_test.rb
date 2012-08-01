require 'test_helper'
require 'iridium/commands/test'

class RunningTestsTest < MiniTest::Unit::TestCase
  def setup
    Iridium.application = TestApp.instance
    Iridium.application.config.dependencies.clear
    Iridium.application.config.load :minispade
    Iridium.application.config.load :qunit

    create_file "app/javascripts/app.js", <<-file
      window.Iridium = true;
    file

    FileUtils.mkdir_p Iridium.application.root.join "app", "dependencies"

    # create files that would be there in a normal app
    File.open Iridium.application.root.join("app", "dependencies", "qunit.js"), "w" do |file|
      file.puts File.read(File.expand_path('../../generators/application/app/dependencies/qunit.js', __FILE__))
    end

    File.open Iridium.application.root.join("app", "dependencies", "minispade.js"), "w" do |file|
      file.puts File.read(File.expand_path('../../generators/application/app/dependencies/minispade.js', __FILE__))
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

  def test_raises_an_error_if_file_does_not_exist
    status, stdout, stderr = invoke "foo.js"

    assert_equal 1, status
    assert_includes stderr, "foo.js"
  end

  def test_runs_a_unit_test_in_javascript
    create_file "test/unit/truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    status, stdout, stderr = invoke "test/unit/truth_test.js"

    assert_equal 0, status
  end

  def test_runs_an_integration_test
    create_file "test/integration/truth_test.js", <<-test
      casper.start('http://localhost:7777/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    status, stdout, stderr = invoke "test/integration/truth_test.js"

    assert_equal 0, status
  end

  def test_pukes_on_invalid_coffee_script
    create_file "test/unit/invalid_coffeescript.coffee", <<-test
      test 'Truth' ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit/invalid_coffeescript.coffee"

    assert_equal 1, status
    assert_includes stderr, "test/unit/invalid_coffeescript.coffee"
    assert_includes stderr, "compiling"
  end

  def test_runs_coffee_script_unit_test
    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/unit/truth.coffee"

    assert_equal 0, status
  end

  def test_runs_coffee_script_integration_test
    create_file "test/integration/truth.coffee", <<-test
      casper.start 'http://localhost:7777/', ->
        this.test.assertHttpStatus(200, 'Server is up')

      casper.run ->
        this.test.done()
    test

    status, stdout, stderr = invoke "test/integration/truth.coffee"

    assert_equal 0, status
  end

  def test_runs_unit_and_integration_tests
    create_file "test/integration/truth.coffee", <<-test
      casper.start 'http://localhost:7777/', ->
        this.test.assertHttpStatus(200, 'Server is up')

      casper.run ->
        this.test.done()
    test

    create_file "test/unit/truth.coffee", <<-test
      test 'Truth', ->
        ok true, "Passed!"
    test

    status, stdout, stderr = invoke "test/integration/truth.coffee", "test/integration/truth.coffee"

    assert_equal 0, status
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

require 'test_helper'

class IntegrationTestRunnerTest < MiniTest::Unit::TestCase
  def invoke(*files)
    results = nil
    options = files.extract_options!
    stdout, stderr = nil, nil

    Dir.chdir Iridium.application.root do
      stdout, stderr = capture_io do
        results = Iridium::TestRunner.new(Iridium.application, files).run(options)
      end
    end

    return results, stdout, stderr
  end

  def test_helper
    <<-str
      class Helper
        scripts: [ ]

        iridium: ->
          _iridium = requireExternal('iridium').create()
          _iridium.scripts = @scripts
          _iridium

      exports.casper = (options) ->
        (new Helper).iridium().casper(options)
    str
  end

  def test_reports_basic_information
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/success.js"

    test_result = results.first
    assert_kind_of Fixnum, test_result.time
    assert_equal 1, test_result.assertions
    assert test_result.name
  end

  def test_reports_successful_test_correctly
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/success.js"
    test_result = results.first
    assert test_result.passed?
  end

  def test_reports_a_failure
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/failure.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(500, 'Server should be down!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/failure.js"
    test_result = results.first
    assert test_result.failed?
    assert_includes test_result.message, "Server should be down!"
    assert_equal 1, test_result.assertions
    assert_equal ["test/integration/failure.js"], test_result.backtrace
  end

  def test_reports_an_error
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        foobar;
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/error.js", :debug => true
    test_result = results.first
    assert test_result.error?
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
    assert_equal "test/integration/error.js:2", test_result.backtrace.first
    assert_equal 0, test_result.assertions
  end

  def test_stdout_prints_in_debug_mode
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        console.log('This is logged!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/error.js", :debug => true
    assert_includes stdout, "This is logged!"
  end

  def test_dry_return_returns_no_results
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        console.log('This is logged!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/error.js", :dry_run => true
    assert_equal [], results
  end

  def test_handles_javascript_errors_in_source_files
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "test/integration/error.js"

    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
    assert test_result.backtrace
    assert_equal 0, test_result.assertions
  end

  def test_does_not_let_one_test_bring_down_others
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    create_file "test/integration/error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "test/integration/error.js", "test/integration/success.js"

    assert_equal 2, results.size
    assert results[0].error?
    assert results[1].passed?
  end

  def test_raises_an_error_when_js_aborts
    create_file "test/helper.coffee", <<-str
      class Helper
        scripts: [
          'this_file_doesnt_exist'
        ]

        iridium: ->
          _iridium = requireExternal('iridium').create()
          _iridium.scripts = @scripts
          _iridium

      exports.casper = ->
        (new Helper).iridium().casper()
    str

    create_file "test/integration/success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    assert_raises Iridium::CommandStreamer::ProcessAborted do
      invoke "test/integration/success.js"
    end
  end

  def test_does_not_report_multiple_failures
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/multiple_assertions.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(false, "This fails!");
        this.test.assert(false, "This fails! too");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/multiple_assertions.js"

    assert_equal 1, results.size
    result = results.first
    assert result.failed?
  end

  def test_internal_assertion_failure_handling_does_not_bring_down_other_tests
    create_file "test/helper.coffee", test_helper

    create_file "test/integration/failing_assertions.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(false, "This fails!");
        this.test.assert(false, "This fails! too");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    create_file "test/integration/truth.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(true, "This passes");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/integration/failing_assertions.js", "test/integration/truth.js"

    assert_equal 2, results.size
  end
end

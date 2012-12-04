require 'test_helper'

class RunningCasperTestsTest < MiniTest::Unit::TestCase
  def invoke(*files)
    results = nil
    options = files.extract_options!
    stdout, stderr = nil, nil

    Dir.chdir Iridium.application.root do
      stdout, stderr = capture_io do
        results = Iridium::Testing::Runner.new(Iridium.application, files).run(options)
      end
    end

    return results, stdout, stderr
  end

  def test_reports_basic_information
    create_file "test/casper/success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/success.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert_equal "test/casper/success.js", test_result.file
    assert_kind_of Fixnum, test_result.time
    assert_equal 1, test_result.assertions, "Assertions should be recorded"
    assert test_result.name
  end

  def test_reports_successful_test_correctly
    create_file "test/casper/success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/success.js"
    test_result = results.first
    assert test_result.passed?
  end

  def test_reports_a_failure
    create_file "test/casper/failure.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(500, 'Server should be down!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/failure.js"
    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.failed?
    assert_includes test_result.message, "Server should be down!"
    assert_equal 1, test_result.assertions
    assert_equal ["test/casper/failure.js"], test_result.backtrace
  end

  def test_reports_an_error
    create_file "test/casper/error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        foobar;
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/error.js"
    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
    assert_equal "test/casper/error.js:2", test_result.backtrace.first
    assert_equal 0, test_result.assertions
  end

  def test_stdout_prints_in_debug_mode
    skip

    create_file "test/casper/error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        phantom.logger.info('This is logged!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/error.js", :debug => true
    assert_includes stdout, "This is logged!"
  end

  def test_dry_return_returns_no_results
    create_file "test/casper/error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        console.log('This is logged!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/error.js", :dry_run => true
    assert_equal [], results
  end

  def test_handles_javascript_errors_in_source_files
    create_file "test/casper/error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "test/casper/error.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
    assert test_result.backtrace
    assert_equal 0, test_result.assertions
  end

  def test_does_not_let_one_test_bring_down_others
    create_file "test/casper/success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    create_file "test/casper/error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "test/casper/error.js", "test/casper/success.js"

    assert_kind_of Array, results
    assert_equal 2, results.size
    assert results[0].error?
    assert results[1].passed?
  end

  def test_does_not_report_multiple_failures
    create_file "test/casper/multiple_assertions.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(false, "This fails!");
        this.test.assert(false, "This fails! too");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/multiple_assertions.js"

    assert_equal 1, results.size
    result = results.first
    assert result.failed?
  end

  def test_internal_assertion_failure_handling_does_not_bring_down_other_tests
    create_file "test/casper/failing_assertions.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(false, "This fails!");
        this.test.assert(false, "This fails! too");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    create_file "test/casper/truth.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(true, "This passes");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/failing_assertions.js", "test/casper/truth.js"

    assert_kind_of Array, results
    assert_equal 2, results.size
  end

  def test_errors_are_reported_multiple_times
    create_file "test/casper/failing_assertions.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(false, "This fails!");
        this.test.assert(false, "This fails! too");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    create_file "test/casper/error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(foo, "This passes");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/failing_assertions.js", "test/casper/error.js"

    assert_kind_of Array, results
    assert_equal 2, results.size
  end

  def test_test_cannot_be_tereminated
    create_file "test/casper/double_termination.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(true);
        this.test.done();
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/double_termination.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
  end

  def test_happy_path_steps_work_correctly
    create_file "test/casper/multiple_steps.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(true)
      });

      casper.then(function() {
        this.test.assert(true)
      });

      casper.then(function() {
        this.test.assert(true)
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/multiple_steps.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    result = results.first
    assert result.passed?
    assert_equal 3, result.assertions
  end

  def test_failed_assertions_halt_the_next_step
    create_file "test/casper/multiple_steps.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(true)
      });

      casper.then(function() {
        this.test.assert(false)
      });

      casper.then(function() {
        this.test.assert(true)
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/multiple_steps.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    result = results.first
    assert result.failed?
    assert_equal 2, result.assertions
  end

  def test_exceptions_halt_the_next_step
    create_file "test/casper/multiple_steps.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assert(true)
      });

      casper.then(function() {
        fooBar();
      });

      casper.then(function() {
        this.test.assert(true)
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/multiple_steps.js"

    assert_equal 1, results.size
    result = results.first
    assert result.error?
    assert_equal 1, result.assertions
  end

  def test_step_timeouts_dont_blow_up_tests
    create_file "test/casper/timeout_test.js", <<-test
      casper.start('http://localhost:7776/', function() {
        casper.waitForSelector("#foo-bar", function() {
          casper.test.assert(false, "This #foo-bar is fake!")
        })
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/timeout_test.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    result = results.first
    assert result.failed?
  end

  def test_die_counts_as_fail
    create_file "test/casper/die_test.js", <<-test
      casper.start('http://localhost:7776/', function() {
        casper.die("EJECT!");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "test/casper/die_test.js"

    assert_kind_of Array, results
    assert_equal 1, results.size
    result = results.first
    assert result.failed?
  end

  def test_warn_triggers_an_abort
    create_file "test/casper/warn_test.js", <<-test
      casper.start('http://localhost:7776/', function() {
        casper.warn("EJECT");
      });

      casper.run(function() {
        this.test.done();
      });
    test

    assert_raises Iridium::Testing::CommandStreamer::ProcessAborted do
      results, stdout, stderr = invoke "test/casper/warn_test.js"
    end
  end
end

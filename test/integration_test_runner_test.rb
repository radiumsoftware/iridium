require 'test_helper'

class IntegrationTestRunnerTest < MiniTest::Unit::TestCase
  def setup
    Iridium.application = TestApp
    FileUtils.mkdir_p working_directory
  end

  def teardown
    Iridium.application = nil
  end

  def invoke(*files)
    results = nil
    options = files.extract_options!
    stdout, stderr = nil, nil

    Dir.chdir working_directory do
      stdout, stderr = capture_io do
        results = Iridium::IntegrationTestRunner.new(files).run(options)
      end
    end

    return results, stdout, stderr
  end

  def working_directory
    Iridium.application.root.join('tmp', 'test_root')
  end

  def create_file(path, content)
    full_path = working_directory.join path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end

  def test_reports_basic_information
    create_file "success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "success.js"
    test_result = results.first
    assert_kind_of Fixnum, test_result.time
    assert_equal 1, test_result.assertions
    assert test_result.name
  end

  def test_reports_successful_test_correctly
    create_file "success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "success.js"
    test_result = results.first
    assert test_result.passed?
  end

  def test_reports_a_failure
    create_file "failure.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(500, 'Server should be down!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr= invoke "failure.js"
    test_result = results.first
    assert test_result.failed?
    assert_includes test_result.message, "Server should be down!"
    assert_equal 1, test_result.assertions
    assert_equal ["failure.js"], test_result.backtrace
  end

  def test_reports_an_error
    create_file "error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        foobar;
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "error.js", :debug => true
    test_result = results.first
    assert test_result.error?
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
    assert_equal "error.js:2", test_result.backtrace.first
    assert_equal 0, test_result.assertions
  end

  def test_stdout_prints_in_debug_mode
    create_file "error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        console.log('This is logged!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "error.js", :debug => true
    assert_includes stdout, "This is logged!"
  end

  def test_dry_return_returns_no_results
    create_file "error.js", <<-test
      casper.start('http://localhost:7776/', function() {
        console.log('This is logged!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results, stdout, stderr = invoke "error.js", :dry_run => true
    assert_equal [], results
  end


  def test_handles_javascript_errors_in_source_files
    create_file "error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "error.js"

    assert_equal 1, results.size
    test_result = results.first
    assert test_result.error?
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
    assert test_result.backtrace
    assert_equal 0, test_result.assertions
  end

  def test_does_not_let_one_test_bring_down_others
    create_file "success.js", <<-test
      casper.start('http://localhost:7776/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    create_file "error.js", <<-test
      foobar();
    test

    results, stdout, stderr = invoke "success.js", "error.js"

    assert_equal 2, results.size
    assert results[0].passed?
    assert results[1].error?
  end
end

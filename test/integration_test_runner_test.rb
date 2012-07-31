require 'test_helper'

class IntegrationTestRunnerTest < MiniTest::Unit::TestCase
  def setup
    Iridium.application = nil
    Iridium.application = Class.new(TestApp) do
      def call(env)
        [200, {}, ["<body>Hello World</body>"]]
      end
    end
    FileUtils.mkdir_p working_directory
  end

  def invoke(*files)
    results = nil
    options = files.extract_options!
    Dir.chdir working_directory do
      capture_io do
        results = Iridium::IntegrationTestRunner.new(files).run(options)
      end
    end

    return results
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
      casper.start('http://localhost:7777/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results = invoke "success.js"
    test_result = results.first
    assert_kind_of Fixnum, test_result.time
    assert_equal 1, test_result.assertions
    assert test_result.name
  end

  def test_reports_successful_test_correctly
    create_file "success.js", <<-test
      casper.start('http://localhost:7777/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results = invoke "success.js"
    test_result = results.first
    assert test_result.passed?
    assert_equal 1, test_result.assertions
  end

  def test_reports_a_failure
    create_file "failure.js", <<-test
      casper.start('http://localhost:7777/', function() {
        this.test.assertHttpStatus(500, 'Server should be down!');
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results = invoke "failure.js"
    test_result = results.first
    assert test_result.failed?
    assert_includes test_result.message, "Server should be down!"
    assert_equal 1, test_result.assertions
    assert_equal ["failure.js"], test_result.backtrace
  end

  def test_reports_an_error
    create_file "error.js", <<-test
      casper.start('http://localhost:7777/', function() {
        foobar;
      });

      casper.run(function() {
        this.test.done();
      });
    test

    results = invoke "error.js"
    test_result = results.first
    assert test_result.error?
    assert_equal "ReferenceError: Can't find variable: foobar", test_result.message
    assert_equal ["error.js:2"], test_result.backtrace
  end

  def teardown
    Iridium.application = nil
  end
end

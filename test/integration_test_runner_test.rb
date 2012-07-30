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
    options = files.extract_options!
    Dir.chdir working_directory do
      Iridium::IntegrationTestRunner.new(files).run(options)
    end
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

  def test_reports_successful_test_correctly
    create_file "success.js", <<-test
      casper = require("casper").create({
      });

      casper.start('http://localhost:7777/', function() {
        this.test.assertHttpStatus(200, 'Server is up');
      });

      casper.run();
    test

    invoke "success.js"
  end

  def test_reports_a_failure
    create_file "failure.js", <<-test
      casper = require("casper").create({
      });

      casper.start('http://localhost:7777/', function() {
        this.test.assertHttpStatus(500, 'Server should be down!');
      });

      casper.run();
    test

    invoke "failure.js"
  end

  def test_reports_an_error
    create_file "error.js", <<-test
      casper = require("casper").create({
      });

      casper.start('http://localhost:7777/', function() {
        foobar;
      });

      casper.run();
    test

    invoke "error.js"
  end

  def teardown
    Iridium.application = nil
  end
end

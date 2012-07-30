require 'test_helper'

class UnitTestRunnerTest < MiniTest::Unit::TestCase
  def setup
    Iridium.application = TestApp.instance
    Iridium.application.config.load :qunit
    FileUtils.mkdir_p working_directory
    File.open working_directory.join("qunit.js"), "w" do |qunit|
      qunit.puts File.read(File.expand_path('../../generators/application/app/dependencies/qunit.js', __FILE__))
    end
  end

  def teardown
    Iridium.application.config.dependencies.clear
    FileUtils.rm_rf working_directory
    Iridium.application = nil
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

  def read(path)
    File.read working_directory.join(path)
  end

  def invoke(*files)
    options = files.extract_options!
    Iridium::UnitTestRunner.new(Iridium.application, files).run(options)
  end

  def test_runner_generates_the_loader_correctly
    create_file "test/support/example.js", "foo"

    invoke "truth.js", "foo/bar.js", :dry_run => true

    test_loader = Dir[working_directory.join("**/*")].select { |f| f =~ /unit_test_runner.+\.html/ }.first
    assert test_loader, "Could not find a loader!"

    content = read File.basename(test_loader)

    assert_includes content, %Q{<script src="truth.js"></script>}
    assert_includes content, %Q{<script src="foo/bar.js"></script>}

    assert_includes content, %Q{<script src="qunit.js"></script>}, "Dependencies should be included!"

    assert_includes content, %Q{<script src="test/support/example.js"></script>}, "Support files should be included!"
  end

  def test_reports_passes
    create_file "truth_test.js", <<-test
      test('Truth', function() {
        ok(true, "Passed!")
      });
    test

    results = invoke "truth_test.js"
    test_result = results.first
    assert test_result.passed?
  end

  def test_reports_assertion_errors
    create_file "failed_assertion.js", <<-test
      test('Failed Assertions', function() {
        ok(false, "failed");
      });
    test

    results = invoke "failed_assertion.js"
    test_result = results.first
    assert test_result.failed?
    assert_equal "failed", test_result.message
  end

  def test_reports_expectation_errors
    create_file "failed_expectation.js", <<-test
      test('Unmet expectation', function() {
        expect(1);
      });
    test

    results = invoke "failed_expectation.js"
    test_result = results.first
    assert test_result.failed?
    assert_match test_result.message, /expect/i
    assert_match test_result.message, /0/
    assert_match test_result.message, /1/
  end
end

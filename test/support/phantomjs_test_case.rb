require 'test_helper'

class PhantomJsTestCase < MiniTest::Unit::TestCase
  def setup
    super

    Iridium.application.config.pipeline.compile_tests = true

    create_test_support_files
  end

  def invoke(opts = "")
    Iridium.application.compile

    output = `phantomjs #{Iridium.phantom_js_test_runner} #{Iridium.application.site_path}/tests.html 2000 #{opts}`

    assert ($?.exitstatus == 0 || $?.exitstatus == 1), "Tests failed unexpectedly! #{output}"

    [output, $?]
  end

  def assert_total_passes(report, count)
    assert_includes report, "Passed: #{count}"
  end

  def assert_total_failures(report, count)
    assert_includes report, "Failed: #{count}"
  end

  def assert_total_tests(report, count)
    assert_includes report, "Total: #{count}"
  end
end

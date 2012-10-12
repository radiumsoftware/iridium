require 'test_helper'

class PipelineHelperTest < MiniTest::Unit::TestCase
  def test_can_access_the_app_inside_the_dsl
    assert Iridium.application

    Rake::Pipeline::Project.build do
      input app.app_path
    end
  end

  def test_an_error_is_raised_when_there_is_no_application
    Iridium.application = nil
    refute Iridium.application

    assert_raises RuntimeError do
      Rake::Pipeline::Project.build do
        input app.app_path
      end
    end
  end
end

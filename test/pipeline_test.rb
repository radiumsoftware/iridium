require 'test_helper'

class PipelineTest < MiniTest::Unit::TestCase
  def create_file(path, content)
    full_path = TestApp.root.join "app", path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end

  def clean_up
    FileUtils.rm_rf TestApp.root.join("app")
    FileUtils.rm_rf TestApp.root.join("site")
    FileUtils.rm_rf TestApp.root.join("tmp")
  end

  def setup
    clean_up
  end

  def teardown
    clean_up
  end

  def assert_file(path)
    full_path = TestApp.root.join "site", path

    assert File.exists?(full_path), 
      "#{full_path} should be a file. Current Files: #{Dir[TestApp.root.join("**", "*").inspect]}"
  end

  def read(path)
    File.read TestApp.root.join("site", path)
  end

  def test_combines_js_into_one_file
    create_file "javascripts/main.js", "Main = {};"
    create_file "javascripts/secondary.js", "Secondary = {};"

    compile

    assert_file "application.js"

    content = read "application.js"

    assert_includes content, "Main = {};"
    assert_includes content, "Secondary = {};"
  end

  def tests_compiles_app_js_into_namespaced_minispade_modules
    create_file "javascripts/main.js", "Main = {};"

    compile ; assert_file "application.js"

    content = read "application.js"

    assert_includes content, %Q{minispade.register('test_app/main'}
  end

  def tests_compiles_vendored_js_into_top_level_modules
    create_file "vendor/javascripts/jquery.js", "jQuery"

    compile ; assert_file "application.js"

    content = read "application.js"

    assert_includes content, %Q{minispade.register('jquery'}
  end


  def tests_compiles_coffee_script
    create_file "javascripts/main.coffee", "square = (x) -> x * x"

    compile ; assert_file "application.js"

    content = read "application.js"

    assert_includes content, %Q{square = function}
  end

  def test_combines_css_into_one_file
    create_file "stylesheets/main.css", ".main"
    create_file "stylesheets/secondary.css", ".secondary;"

    compile

    assert_file "application.css"

    content = read "application.css"

    assert_includes content, ".main"
    assert_includes content, ".secondary"
  end

  def tests_compiles_scss
    create_file "stylesheets/app.scss", "#this-selector { color: black; }"

    compile ; assert_file "application.css"

    content = read "application.css"

    assert_includes content, %Q{#this-selector}
  end

  def tests_compiles_less
    less_css = <<-LESS
    @color: #4D926F;

    #header {
      color: @color;
    }
    LESS

    create_file "stylesheets/app.less", less_css

    compile ; assert_file "application.css"

    content = read "application.css"

    assert_includes content, %Q{color: #4d926f;}
  end

  def tests_compiles_handle_bars_into_js_file
    create_file "javascripts/home.handlebars", "{{#name}}"

    compile ; assert_file "application.js"

    content = read "application.js"

    assert_includes content, "{{#name}}"
  end

  def test_concats_vendor_css_before_app_css
    create_file "stylesheets/home.css", "#second-selector"
    create_file "stylesheets/vendor/bootstrap.css", "#first-selector"

    compile ; assert_file "application.css"

    content = read "application.css"

    assert content.index("#first-selector") < content.index("#second-selector"),
      "#first-selector should come before #second-selector in compiled css file"
  end

  def test_concats_vendor_css_ordered_by_name
    create_file "stylesheets/vendor/z_file.css", "#second-selector"
    create_file "stylesheets/vendor/a_file.css", "#first-selector"

    compile ; assert_file "application.css"

    content = read "application.css"

    assert content.index("#first-selector") < content.index("#second-selector"),
      "#first-selector should come before #second-selector in compiled css file"
  end

  def test_concats_css_ordered_by_name
    create_file "stylesheets/z_file.css", "#second-selector"
    create_file "stylesheets/a_file.css", "#first-selector"

    compile ; assert_file "application.css"

    content = read "application.css"

    assert content.index("#first-selector") < content.index("#second-selector"),
      "#first-selector should come before #second-selector in compiled css file"
  end

  private
  def compile
    TestApp.compile_assets
  end
end

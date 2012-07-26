require 'test_helper'

class PipelineTest < MiniTest::Unit::TestCase
  def create_file(path, content)
    full_path = TestApp.root.join "app", path

    @created_files << full_path

    FileUtils.mkdir_p File.dirname(full_path)

    File.open full_path, "w" do |f|
      f.puts content
    end
  end

  def setup
    @created_files = []
    Iridium.application = TestApp.instance
  end

  def teardown
    Iridium.application = nil
    FileUtils.rm_rf TestApp.root.join("app")
    FileUtils.rm_rf TestApp.root.join("site")
    FileUtils.rm_rf TestApp.root.join("tmp")

    @created_files.each do |path|
      FileUtils.rm_rf path
    end
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

  def test_rewrites_requrires_to_use_minispade
    create_file "javascripts/main.js", "require('foo');"

    compile ; assert_file "application.js"

    content = read "application.js"

    assert_includes content, %{minispade.require('foo');}
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

  def test_does_not_compile_scss_partials
    create_file "stylesheets/app.scss", "#this-selector { color: black; }"
    create_file "stylesheets/_partial.scss", "#partial { color: black; }"

    compile ; assert_file "application.css"

    content = read "application.css"

    refute_includes content, %Q{#partial}
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

  def tests_copies_dependenencies_into_public
    create_file "dependencies/faye.min.js", "window.faye = {}"

    compile ; assert_file "faye.min.js"
  end

  def tests_copies_public_files_into_public
    create_file "public/faye.min.js", "window.faye = {}"

    compile ; assert_file "faye.min.js"
  end

  def tests_copies_image_files_into_public
    create_file "images/logo.png", "png-content"

    compile ; assert_file "images/logo.png"
  end

  def tests_provides_the_server_for_erb_templates
    create_file "public/index.html.erb", <<-str
    <%= app.config %>
    str

    compile ; assert_file "index.html"
  end

  def test_server_can_accept_an_asset_file
    assetfile = <<-str
      output "site"

      input "app/foos" do
        match "**/*" do
          copy
        end
      end
    str

    create_file "../Assetfile", assetfile
    create_file "foos/index.html", "bar"

    compile ; assert_file "index.html"
  end

  private
  def compile
    TestApp.compile
  end
end

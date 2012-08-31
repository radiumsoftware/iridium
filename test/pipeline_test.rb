require 'test_helper'

class PipelineTest < MiniTest::Unit::TestCase
  def index_file_content
    path = File.expand_path "../../generators/application/app/index.html.erb.tt", __FILE__

    ERB.new(File.read(path)).result(binding)
  end

  # For the template
  def camelized
    Iridium.application.class.to_s.camelize
  end

  def underscored
    Iridium.application.class.to_s.underscore
  end

  def create_index
    create_file "app/index.html.erb", index_file_content
  end

  def test_index_is_copied_over_correctly
    create_index

    compile ; assert_file "site/index.html"
  end

  def test_combines_js_into_one_file
    create_file "app/javascripts/main.js", "Main = {};"
    create_file "app/javascripts/secondary.js", "Secondary = {};"

    compile

    assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "Main = {};"
    assert_includes content, "Secondary = {};"
  end

  def tests_compiles_app_js_into_namespaced_minispade_modules
    create_file "app/javascripts/main.js", "Main = {};"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, %Q{minispade.register('test_app/main'}
  end

  def test_rewrites_requrires_to_use_minispade
    create_file "app/javascripts/main.js", "require('foo');"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, %{minispade.require('foo');}
  end

  def tests_compiles_coffee_script
    create_file "app/javascripts/main.coffee", "square = (x) -> x * x"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, %Q{square = function}
  end

  def test_combines_css_into_one_file
    create_file "app/stylesheets/main.css", ".main"
    create_file "app/stylesheets/secondary.css", ".secondary;"

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_includes content, ".main"
    assert_includes content, ".secondary"
  end

  def tests_compiles_scss
    create_file "app/stylesheets/app.scss", "#this-selector { color: black; }"

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_includes content, %Q{#this-selector}
  end

  def tests_compiles_sass
    create_file "app/stylesheets/app.sass", <<-sass
#this-selector
  color: black
    sass

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_includes content, %Q{#this-selector}
  end

  def test_does_not_compile_scss_partials
    create_file "app/stylesheets/app.scss", "#this-selector { color: black; }"
    create_file "app/stylesheets/_partial.scss", "#partial { color: black; }"

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    refute_includes content, %Q{#partial}
  end

  def test_does_not_compile_sass_partials
    create_file "app/stylesheets/app.sass", <<-sass
#this-selector
  color: black
    sass

    create_file "app/stylesheets/_partial.sass", <<-sass
#partial 
  color: black
    sass

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    refute_includes content, %Q{#partial}
  end

  def tests_compiles_handlebars_into_js_file
    create_file "app/index.html", index_file_content
    create_file "app/templates/home.handlebars", "{{name}}"

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_match content, /<head>(.+)<\/head>/m, "<head> tag incorrect!"
    assert_equal 1, content.scan("<html>").size, "HTML double appended!"
    assert_includes content, %Q{<script type="text/x-handlebars" data-template-name="home">}
  end

  def test_compiling_handle_bars_does_not_erase_existing_head_content
    existing_head_tag = index_file_content.match(/<head>(.+)<\/head>/m)[1]

    refute_empty existing_head_tag

    create_file "app/index.html", index_file_content
    create_file "app/templates/home.handlebars", "{{name}}"

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, existing_head_tag, "Existing content was erased!"
    assert_includes content, %Q{<script type="text/x-handlebars" data-template-name="home">}
  end

  def tests_maps_path_handlebars_template_name
    create_file "app/index.html", index_file_content
    create_file "app/templates/dashboard/feed/header.handlebars", "{{name}}"

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, %Q{<script type="text/x-handlebars" data-template-name="dashboard/feed/header">}
  end

  def test_concats_vendor_css_before_app_css
    create_file "app/stylesheets/home.css", "app"
    create_file "vendor/stylesheets/bootstrap.css", "vendor"

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_includes content, "app"
    assert_includes content, "vendor"
    assert content.index("vendor") < content.index("app"),
      "vendor css should come before app css!"
  end

  def tests_copies_assets
    create_file "app/assets/faye.min.js", "window.faye = {}"

    compile ; assert_file "site/faye.min.js"
  end

  def test_asset_directory_is_preserved
    create_file "app/assets/images/logo.png", "png content"

    compile ; assert_file "site/images/logo.png"
  end

  def tests_provides_the_server_for_erb_templates
    create_file "app/index.html.erb", <<-str
    <%= app.config %>
    str

    compile ; assert_file "site/index.html"
  end

  def test_compiles_vendor_javascripts_when_nothing_is_specified
    create_file "vendor/javascripts/file1.js", "var file1 = {};"
    create_file "vendor/javascripts/file2.js", "var file2 = {};"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "file1"
    assert_includes content, "file2"
  end

  def test_specified_vendor_dependencies_come_before_unspecified_dependencies
    create_file "vendor/javascripts/file1.js", "var file1 = {};"
    create_file "vendor/javascripts/file2.js", "var file2 = {};"

    Iridium.application.config.load :file2

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "file1"
    assert_includes content, "file2"
    assert content.index("file2") < content.index("file1"), 
      "File2 should be included before file1"
  end

  def test_unspecifed_dependencies_come_after_specified_dependencies
    create_file "vendor/javascripts/jquery.js", "var jquery = {};"
    create_file "vendor/javascripts/jquery_ui.js", "var jqui = {};"
    create_file "vendor/javascripts/underscore.js", "var underscore = {};"

    Iridium.application.config.load :jquery
    Iridium.application.config.load :jquery_ui

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "jquery"
    assert_includes content, "jqui"
    assert_includes content, "underscore"
    assert content.index("jquery") < content.index("jqui"), 
      "jquery should be included before jquery_ui"

    assert content.index("jqui") < content.index("underscore"), 
      "jquery_ui should be included before underscore"
  end

  def test_vendored_code_comes_before_app_code
    create_file "vendor/javascripts/jquery.js", "var jquery = {};"
    create_file "app/javascripts/app.js", "var MyApp = {};"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert content.index("jquery") < content.index("MyApp"), 
      "jquery should be included before MyApp"
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

    create_file "Assetfile", assetfile
    create_file "app/foos/index.html", "bar"

    compile ; assert_file "site/index.html"

    assert_equal "bar", read("site/index.html").chomp
  end

  def test_compiles_minifies
    Iridium.application.config.minify = true

    create_file "vendor/javascripts/jquery.js", "var jquery = {};"
    create_file "app/javascripts/app.js", "var MyApp = {};"

    create_file "app/stylesheets/app.csss", "#foo { color: black; }"
    create_file "vendor/stylesheets/app.csss", "#foo { color: black; }"

    compile ; assert_file "site/application.js"
  ensure
    Iridium.application.config.minify = false
  end

  def test_generates_gzip_versions
    Iridium.application.config.gzip = true

    create_file "app/javascripts/app.js", "var fooBar = {};"

    compile

    assert_file "site/application.js"
    assert_file "site/application.js.gz"
  ensure
    Iridium.application.config.gzip = false
  end

  def test_generates_a_cache_manifest
    Iridium.application.config.manifest = true

    create_file "app/javascripts/app.js", "var MyApp = {};"
    create_file "app/assets/images/logo.png", "image content"

    compile ; assert_file "site/cache.manifest"

    content = read "site/cache.manifest"

    assert_includes content, "application.js"
    assert_includes content, "images/logo.png"
  ensure
    Iridium.application.config.manifest = false
  end

  def test_includes_a_cache_manifest
    Iridium.application.config.manifest = true

    create_index

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, %q{<html manifest="/cache.manifest">}
  ensure
    Iridium.application.config.manifest = false
  end

  def test_compiles_yml_files_into_i18n_translations
    create_file "app/locales/en.yml", <<-EN
      en:
        hello: Hello!
    EN

    create_file "app/locales/de.yml", <<-DE
      de:
        hello: Hallo!
    DE

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "I18n.translations = "
  end

  def test_inserts_translations_after_i18n
    create_file "app/locales/en.yml", <<-EN
      en:
        hello: Hello!
    EN

    create_file "app/locales/de.yml", <<-DE
      de:
        hello: Hallo!
    DE

    create_file "vendor/javascripts/i18n.js", "I18n = {};"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert content.index("I18n = {};") < content.index("I18n.translations = "), 
      "Translations dictionary must be loaded after I18n"
  end

  def test_intializers_are_compiles
    create_file "app/config/initializers/bar.js", "INIT"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "INIT"
  end

  def test_initializers_are_wrapped_in_iifes
    create_file "app/config/initializers/foo.js", "FOO"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_equal "(function() {\nFOO\n})();", content.chomp
  end

  def test_index_boots_the_app
    create_index

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, %q{minispade.require("test_app/boot");}
  end

  def test_index_contains_scripts
    create_index

    Iridium.application.config.scripts << "http://jquery.com/jquery.js"

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, %q{<script src="http://jquery.com/jquery.js"></script>}
  end


  def test_pipeline_includes_env_specific_js_code
    ENV['IRIDIUM_ENV'] = 'foo'

    create_file "app/config/test.js", "test"
    create_file "app/config/foo.js", "foo"

    compile ; assert_file "site/application.js"

    content = read 'site/application.js'

    assert_includes content, "foo"
    refute_includes content, "test"
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_pipeline_wraps_env_code_in_an_iife
    ENV['IRIDIUM_ENV'] = 'foo'

    create_file "app/config/foo.js", "foo"

    compile ; assert_file "site/application.js"

    content = read 'site/application.js'

    assert_equal "(function() {\nfoo\n})();", content.chomp
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_build_order
    create_file "vendor/javascripts/foo.js", "VENDOR"
    create_file "app/config/initializers/bar.js", "INITIALIZER"
    create_file "app/config/test.js", "ENV"
    create_file "app/javascripts/app.js", "APP"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "VENDOR", "Vendored code not loaded!"
    assert_includes content, "INITIALIZER", "Init code not loaded!"
    assert_includes content, "ENV", "Env code not loaded!"
    assert_includes content, "APP", "App code not loaded!"

    assert content.index("VENDOR") < content.index("ENV"), 
      "Vendored code must be loaded before environment initialization!"

    assert content.index("ENV") < content.index("INITIALIZER"), 
      "Environment must be prepared for initialization!"

    assert content.index("INITIALIZER") < content.index("APP"), 
      "App code must be loaded after initialization"
  end

  private
  def compile
    TestApp.compile
  end
end

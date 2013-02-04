require 'test_helper'

class AssetPipelineTest < MiniTest::Unit::TestCase
  class AppendingFilter < Rake::Pipeline::Filter
    def generate_output(inputs, output)
      inputs.each do |input|
        output.write input.read
        output.write "Appending Filter"
      end
    end
  end

  def setup
    super
    FileUtils.mkdir_p Iridium.application.root.join("external")
    Iridium.application.boot!
  end

  def teardown
    config.minispade.clear
    config.handlebars.clear
    config.pipeline.clear
    FileUtils.rm_rf Iridium.application.root.join("external")
    super
  end

  def index_file_content
    ERB.new(File.read(INDEX_FILE_PATH)).result(binding)
  end

  # For the template
  def camelized
    Iridium.application.class.to_s.camelize
  end

  def underscored
    Iridium.application.class.to_s.underscore
  end

  def create_index
    create_file "app/assets/index.html.erb", index_file_content
  end

  def config
    Iridium.application.config
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

  def tests_compiles_app_js_into_string_minispade_modules
    config.minispade.module_format = :string

    create_file "app/javascripts/main.js", "Main = {};"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, %Q{sourceURL=main}
  end

  def tests_compiles_app_js_into_modules
    config.minispade.module_format = :function

    create_file "app/javascripts/main.js", "FOO"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_match content, /function\(\)\s*{FOO\s*}/m
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

  def test_compiles_lib_js_files_into_minispade_modules
    create_file "lib/foo/bar.js", "LIB"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "LIB"
    assert_minispade content, "lib/foo/bar"
  end

  def test_compiles_lib_cs_files_into_minispade_modules
    create_file "lib/foo/bar.coffee", "a = 'LIB'"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "LIB"
    assert_minispade content, "lib/foo/bar"
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
    create_file "app/templates/home.handlebars", "{{name}}"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "Handlebars.TEMPLATES['home']="
    assert_includes content, "{{name}}"
    assert_includes content, "Handlebars.compile"
  end

  def tests_maps_path_handlebars_template_name
    create_file "app/templates/dashboard/feed/header.handlebars", "{{name}}"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "Handlebars.TEMPLATES['dashboard/feed/header']="
  end

  def test_removes_view_from_handlebars_template_name
    create_file "app/templates/dashboard/feed/header_view.handlebars", "{{name}}"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "Handlebars.TEMPLATES['dashboard/feed/header']="
  end

  def test_handlebars_namespace_is_configurbale
    config.handlebars.namespace = "foo"

    create_file "app/templates/home.handlebars", "{{name}}"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "Handlebars.TEMPLATES['foo/home']="
  end

  def test_handlebars_destination_is_configurbale
    config.handlebars.target = "FOO"

    create_file "app/templates/home.handlebars", "{{name}}"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "FOO['home']="
  end

  def test_handlebars_wrapper_is_configurable
    config.handlebars.compiler = proc { |source| 
      "Pizza.compile(#{source});"
    }

    create_file "app/templates/home.handlebars", "{{name}}"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "Pizza.compile"
  end

  def test_handlebars_files_work_with_precompilation
    create_file "vendor/javascripts/handlebars.js", File.read(Iridium.vendor_path.join("handlebars.js"))

    config.handlebars.compiler = Iridium::Pipeline::HandlebarsFilePrecompiler

    create_file "app/templates/home.handlebars", "{{name}}"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_match content, %r{Handlebars\.TEMPLATES\['home'\]=Handlebars\.template\(.+\);}m
  end

  def test_inline_coffeescript_block_templates_with_line_breaks_are_compiled
    TestApp.configure do
      js do |pipeline|
        pipeline.filter Iridium::Pipeline::InlinePrecompilerFilter
      end
    end

    create_file "vendor/javascripts/handlebars.js", File.read(Iridium.vendor_path.join("handlebars.js"))

    create_file "app/javascripts/view.coffee", <<-coffee
      template: Handlebars.compile '''
        <h2>{{unbound view.title}}</h2>
        <ul>
          {{#each view.content}}
            {{view view.resultItemView 
              contentBinding="this" 
              selectedItemBinding="view.selectedItem"}}
          {{/each}}
        </ul>
      '''
    coffee

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_match content, %r{template:\sHandlebars\.template\(.+\);}m
  end

  def test_inline_coffeescript_block_templates_with_line_breaks_are_compiled
    TestApp.configure do
      js do |pipeline|
        pipeline.filter Iridium::Pipeline::InlinePrecompilerFilter
      end
    end

    create_file "vendor/javascripts/handlebars.js", File.read(Iridium.vendor_path.join("handlebars.js"))

    create_file "app/javascripts/view.coffee", <<-coffee
      template: Handlebars.compile '''
        <h2>{{unbound view.title}}</h2>
        <ul>
          {{#each view.content}}
            {{view view.resultItemView contentBinding="this" selectedItemBinding="view.selectedItem"}}
          {{/each}}
        </ul>
      '''
    coffee

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_match content, %r{template:\sHandlebars\.template\(.+\);}m
  end

  def test_inline_javascript_templates_are_compiled
    TestApp.configure do
      js do |pipeline|
        pipeline.filter Iridium::Pipeline::InlinePrecompilerFilter
      end
    end

    create_file "vendor/javascripts/handlebars.js", File.read(Iridium.vendor_path.join("handlebars.js"))

    create_file "app/javascripts/view.js", <<-coffee
      template: Handlebars.compile("{{foo}}")
    coffee

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_match content, %r{template:\sHandlebars\.template\(.+\);}m
  end

  def test_concats_vendor_css_before_app_css
    create_file "app/stylesheets/home.css", "app"
    create_file "vendor/stylesheets/bootstrap.css", "vendor"

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_before content, "vendor", "app"
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
    create_file "app/assets/index.html.erb", <<-str
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

    config.dependencies.load :file2

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_before content, "file2", "file1"
  end

  def test_unspecifed_dependencies_come_after_specified_dependencies
    create_file "vendor/javascripts/jquery.js", "JQUERY"
    create_file "vendor/javascripts/jquery_ui.js", "UI"
    create_file "vendor/javascripts/underscore.js", "UNDERSCORE"

    config.dependencies.load :jquery_ui
    config.dependencies.load :jquery

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_before content, "UI", "JQUERY"
    assert_before content, "UI", "UNDERSCORE"
  end

  def test_vendored_code_comes_before_app_code
    create_file "vendor/javascripts/jquery.js", "var jquery = {};"
    create_file "app/javascripts/app.js", "var MyApp = {};"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_before content, "jquery", "MyApp"
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

  def test_minifies_js
    config.pipeline.minify = true

    create_file "app/javascripts/app.js", <<-js
      var App = function() {
        console.log("APP");
      };
    js

    create_file "vendor/javascripts/vendor.js", <<-js
      var vendor = function() {
        console.log("VENDOR");
      };
    js

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "APP"
    assert_includes content, "VENDOR"
    refute_includes content, "\n"
  end

  def test_minifies_css
    config.pipeline.minify = true

    create_file "app/stylesheets/app.css", <<-js
      #APP {
       new-lines: everywhere;
      };
    js

    create_file "vendor/stylesheets/vendor.css", <<-js
      #VENDOR {
       new-lines: everywhere;
      };
    js

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_includes content, "APP"
    assert_includes content, "VENDOR"
    refute_includes content, "\n"
  end

  def test_generates_gzip_versions
    config.pipeline.gzip = true

    create_file "app/javascripts/app.js", "var fooBar = {};"

    compile

    assert_file "site/application.js"
    assert_file "site/application.js.gz"
  end

  def test_gzip_ignores_project_files
    config.pipeline.gzip = true

    create_file "readme.md", "This is my readme.md"

    compile

    refute_file "site/readme.md"
    refute_file "site/readme.md.gz"
  end

  def test_generates_a_cache_manifest
    config.pipeline.manifest = true

    create_file "app/javascripts/app.js", "var MyApp = {};"
    create_file "app/assets/images/logo.png", "image content"

    compile 

    assert_file "site/cache.manifest"
    assert_file "site/images/logo.png"
    assert_file "site/application.js"

    content = read "site/cache.manifest"

    assert_match content, /^application\.js$/
    assert_match content, /^images\/logo\.png$/
  end

  def test_index_file_loads_the_manifest
    config.pipeline.manifest = true

    create_index

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, %q{<html manifest="/cache.manifest">}
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

  def test_translations_are_merged
    create_file "app/locales/en.yml", <<-EN
      en:
        hello: Hello!
    EN

    create_file "app/locales/more_en.yml", <<-DE
      en:
        greeting: Yo!
    DE

    compile ; assert_file "site/application.js"

    content = read "site/application.js"
    assert_includes content, "Yo!"
    assert_includes content, "Hello!"
  end

  def test_intializers_are_compiles
    create_file "app/config/initializers/bar.js", "INIT"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "INIT"
  end

  def test_initializers_are_wrapped_in_iifes
    config.pipeline.source_maps = true

    create_file "app/config/initializers/foo.js", "FOO"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_match /\(function\(\) {.+FOO.+}\)\(\);/m, content.chomp
    assert_includes content.chomp, ";//@ sourceURL=foo.js"
  end

  def test_initializers_have_rewritten_requires
    create_file "app/config/initializers/foo.js", "require('app/foo/bar');"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "minispade.require('app/foo/bar'"
  end

  def test_index_boots_the_app
    create_index

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, %q{minispade.require("boot");}
  end

  def test_index_contains_scripts
    create_index

    config.scripts << "http://jquery.com/jquery.js"

    compile ; assert_file "site/index.html"

    content = read "site/index.html"

    assert_includes content, %q{<script src="http://jquery.com/jquery.js"></script>}
  end

  def test_application_environment_is_compiled
    create_file "app/config/application.js", "ENV"

    compile ; assert_file "site/application.js"

    content = read 'site/application.js'
    assert_includes content, "ENV"
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

  def test_env_files_have_rewritten_requires
    ENV['IRIDIUM_ENV'] = 'foo'

    create_file "app/config/foo.js", "require('foo/bar');"

    compile ; assert_file "site/application.js"

    content = read 'site/application.js'

    assert_includes content, "minispade.require('foo/bar", "require should rewrite to minispade.require"
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_pipeline_wraps_env_code_in_an_iife
    ENV['IRIDIUM_ENV'] = 'foo'

    create_file "app/config/foo.js", "foo"

    compile ; assert_file "site/application.js"

    content = read 'site/application.js'

    assert_match /\(function\(\) {.+foo.+}\)\(\);/m, content.chomp
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_non_env_files_are_not_included
    ENV['IRIDIUM_ENV'] = 'foo'

    create_file "app/config/bar.coffee", "q = 'BAR'"
    create_file "app/config/foo.js", "FOO"

    compile ; assert_file "site/application.js"

    content = read 'site/application.js'

    assert_includes content, "FOO", "Env file not compiled"
    refute_includes content, "BAR", "Non env file compiled!"
  ensure
    ENV['IRIDIUM_ENV'] = 'test'
  end

  def test_js_pipeline_build_order
    create_file "vendor/javascripts/foo.js", "VENDOR"
    create_file "lib/foo.js", "LIB"
    create_file "app/config/application.js", "GLOBAL_ENV"
    create_file "app/config/initializers/bar.js", "INIT"
    create_file "app/config/test.js", "CURRENT_ENV"
    create_file "app/javascripts/app.js", "APP"
    create_file "app/templates/foo.hbs", "TEMPLATE"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_before content, "VENDOR", "LIB"
    assert_before content, "LIB", "GLOBAL_ENV"
    assert_before content, "GLOBAL_ENV", "CURRENT_ENV"
    assert_before content, "CURRENT_ENV", "INIT"
    assert_before content, "INIT", "APP"
    assert_before content, "APP", "TEMPLATE"
  end

  def test_sprites_are_compiled
    sprite_path = Iridium.application.app_path.join "sprites"

    FileUtils.mkdir_p sprite_path.join("icons")

    FileUtils.cp fixtures_path.join("images", "icon1.png"), sprite_path.join("icons", "icon1.png")
    FileUtils.cp fixtures_path.join("images", "icon1.png"), sprite_path.join("icons", "icon2.png")

    create_file "app/stylesheets/app.scss", <<-scss
      @import "icons/*.png";
      @include all-icons-sprites;
    scss

    compile

    assert_file "site/application.css"

    content = read "site/application.css"

    assert_match content, %r{/images/icons-\w+.png}, "Compiled CSS does not point to the correct image"

    assert_file "site/images/icons-s0d4ab78e54.png"

    refute_file "site/images/sprites/icons/icon1.png"
  end

  def test_stylesheets_can_import_stylesheets_from_the_same_directory
    create_file "app/stylesheets/mixins.scss", <<-scss
      #foo { } 
    scss

    create_file "app/stylesheets/app.scss", <<-scss
      @import "mixins"
    scss

    compile

    assert_file "site/application.css"
  end

  def test_stylesheets_can_import_stylesheets_from_vendor
    create_file "vendor/stylesheets/mixins.scss", <<-scss
      #foo { } 
    scss

    create_file "app/stylesheets/app.scss", <<-scss
      @import "mixins"
    scss

    compile

    assert_file "site/application.css"
  end

  def test_components_can_add_to_the_js_pipeline
    config.js_pipelines.add do |pipeline|
      pipeline.match "**/*.js" do
        filter AppendingFilter
      end
    end

    create_file "app/javascripts/app.js", "foo"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    assert_includes content, "Appending Filter"
  end

  def test_components_can_add_to_the_css_pipeline
    config.css_pipelines.add do |pipeline|
      pipeline.match "**/*.css" do
        filter AppendingFilter
      end
    end

    create_file "app/stylesheets/application.css", "foo"

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_includes content, "Appending Filter"
  end

  def test_components_ccan_add_to_the_optimization_pipeline
    config.optimization_pipelines.add do |pipeline|
      pipeline.match "**/*" do
        filter AppendingFilter
      end
    end

    create_file "app/stylesheets/application.css", "foo"

    compile ; assert_file "site/application.css"

    content = read "site/application.css"

    assert_includes content, "Appending Filter"
  end

  def test_components_can_swap_out_js_dependencies
    config.dependencies.load :handlebars
    config.dependencies.swap :handlebars, :handlebars_vm

    create_file "vendor/javascripts/handlebars.js", "full handlebars"
    create_file "vendor/javascripts/handlebars_vm.js", "handlebars vm"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"

    refute_includes content, "full handlebars"
    assert_includes content, "handlebars vm"
  end

  def test_engine_vendor_javascript_comes_before_app_vendor_js
    create_file "external/vendor/javascripts/engine.js", "engine"
    create_file "vendor/javascripts/app.js", "app"

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    assert_before content, "engine", "app"
  end

  def test_engine_vendor_javascript_is_overriden_by_app_js
    create_file "external/vendor/javascripts/ember.js", "engine"
    create_file "vendor/javascripts/ember.js", "app"

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    refute_includes content, "engine"
    assert_includes content, "app"
  end

  def test_engines_configurations_come_before_app_configurations
    create_file "external/app/config/test.js", "engine"
    create_file "app/config/test.js", "app"

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    assert_before content, "engine", "app"
  end

  def test_engines_initializers_come_before_app_initializers
    create_file "external/app/config/initializers/engine.js", "engine"
    create_file "app/config/initializers/app.js", "app"

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    assert_before content, "engine", "app"
  end

  def test_engine_locales_come_before_app_locales
    create_file "external/app/locales/engine.yml", <<-EN
      en:
        hello: engine!
    EN

    create_file "app/locales/app.yml", <<-DE
      de:
        hello: app!
    DE

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    assert_before content, "engine", "app"
  end

  def test_app_locales_overwrite_engine_locales
    create_file "external/app/locales/proper.yml", <<-EN
      en:
        hello: Hello!
    EN

    create_file "app/locales/adam.yml", <<-DE
      en:
        hello: Yo!
    DE

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    refute_includes content, "Hello!"
    assert_includes content, "Yo!"
  end

  def test_engine_javascript_gets_its_own_namespace
    create_file "external/app/javascripts/foo.js", "engine"

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    assert_minispade content, "test_engine/foo"
  end

  def test_engines_can_add_their_own_templates
    create_file "external/app/templates/foo.hbs", "engine"

    compile ; assert_file "site/application.js"
    content = read "site/application.js"

    assert_includes content, %Q{Handlebars.TEMPLATES['foo']=}
  end

  def test_engine_vendor_css_comes_before_app_vendor_css
    create_file "external/vendor/stylesheets/engine.css", "engine"
    create_file "vendor/stylesheets/app.css", "app"

    compile ; assert_file "site/application.css"
    content = read "site/application.css"

    assert_before content, "engine", "app"
  end

  def test_engine_css_comes_before_app_css
    create_file "external/app/stylesheets/engine.css", "engine"
    create_file "app/stylesheets/app.css", "app"

    compile ; assert_file "site/application.css"
    content = read "site/application.css"

    assert_before content, "engine", "app"
  end

  def test_engine_vendor_css_is_overridden_by_vendor_app_css
    create_file "external/vendor/stylesheets/bootstrap.css", "engine"
    create_file "vendor/stylesheets/bootstrap.css", "app"

    compile ; assert_file "site/application.css"
    content = read "site/application.css"

    refute_includes content, "engine"
    assert_includes content, "app"
  end

  def test_engine_assets_are_copied_over
    create_file "external/app/assets/engine.asset", "engine"

    compile ; assert_file "site/engine.asset"
  end

  def test_engine_sprites_can_be_imported
    sprite_path = Iridium.application.root.join "external", "app", "sprites"

    FileUtils.mkdir_p sprite_path.join("icons")

    FileUtils.cp fixtures_path.join("images", "icon1.png"), sprite_path.join("icons", "icon1.png")
    FileUtils.cp fixtures_path.join("images", "icon1.png"), sprite_path.join("icons", "icon2.png")

    create_file "app/stylesheets/app.scss", <<-scss
      @import "icons/*.png";
      @include all-icons-sprites;
    scss

    compile

    assert_file "site/application.css"

    content = read "site/application.css"

    assert_match content, %r{/images/icons-\w+.png}, "Compiled CSS does not point to the correct image"

    assert_file "site/images/icons-s0d4ab78e54.png"

    refute_file "site/images/sprites/icons/icon1.png"
  end

  def test_vendored_assets_are_compiled
    create_file "vendor/assets/images/foo.png", "PNG content"

    compile ; assert_file "site/images/foo.png"
  end

  def test_tests_are_compiled
    config.pipeline.compile_tests = true
    config.pipeline.source_maps = true

    create_file "test/foo_test.js", "TEST"

    compile ; assert_file "site/tests.js"

    content = read "site/tests.js"
    assert_includes content, "TEST"
    assert_includes content, "//@ sourceURL=foo_test.js"
  end

  def test_specs_are_compiled
    config.pipeline.compile_tests = true
    config.pipeline.source_maps = true

    create_file "test/foo_spec.js", "TEST"

    compile ; assert_file "site/tests.js"

    content = read "site/tests.js"
    assert_includes content, "TEST"
    assert_includes content, "//@ sourceURL=foo_spec.js"
  end

  def test_test_coffee_script_tests_are_compiled
    config.pipeline.compile_tests = true

    create_file "test/foo_test.coffee", "TEST = true"

    compile ; assert_file "site/tests.js"

    content = read "site/tests.js"
    assert_includes content, "TEST"
  end

  def test_test_coffee_script_specs_are_compiled
    config.pipeline.compile_tests = true

    create_file "test/foo_spec.coffee", "TEST = true"

    compile ; assert_file "site/tests.js"

    content = read "site/tests.js"
    assert_includes content, "TEST"
  end

  def test_test_support_files_are_included_before_test_code
    config.pipeline.compile_tests = true
    config.pipeline.source_maps = true

    create_file "test/foo_test.js", "TEST"
    create_file "test/support/helper.js", "SUPPORT"

    compile ; assert_file "site/tests.js"
    content = read "site/tests.js"

    assert_before content, "SUPPORT", "TEST"
    assert_includes content, "//@ sourceURL=support/helper.js"
  end

  def test_test_framework_code_is_loaded_before_support_code
    config.pipeline.compile_tests = true

    create_file "test/framework/framework.js", "FRAMEWORK"
    create_file "test/foo_test.js", "TEST"
    create_file "test/support/helper.js", "SUPPORT"

    compile ; assert_file "site/tests.js"
    content = read "site/tests.js"

    assert_before content, "FRAMEWORK", "SUPPORT"
  end

  def test_test_loader_is_copied_over
    config.pipeline.compile_tests = true

    create_file "test/framework/loader.html", "LOADER"

    compile ; assert_file "site/tests.html"
  end

  def test_test_loader_runs_through_erb
    config.pipeline.compile_tests = true

    create_file "test/framework/loader.html.erb", "LOADER"

    compile ; assert_file "site/tests.html"
  end

  def test_other_html_files_are_copied_over
    config.pipeline.compile_tests = true

    create_file "test/framework/app_frame.html", "app_frame"

    compile ; assert_file "site/app_frame.html"
  end

  def test_test_framework_css_is_compiled
    config.pipeline.compile_tests = true

    create_file "test/framework/qunit.css", "CSS"

    compile ; assert_file "site/tests.css"

    content = read "site/tests.css"
    assert_includes content, "CSS"
  end

  def test_application_env_is_included
    create_file "app/javascripts/app.js", "APP"

    compile ; assert_file "site/application.js"

    content = read "site/application.js"
    assert_includes content, %Q{Iridium.env = '#{Iridium.env}';}
  end

  def assert_before(string, before, after, msg = nil)
    assert_includes string, before
    assert_includes string, after
    assert string.index(before) < string.index(after), (msg || "#{before} should be before #{after}")
  end

  def assert_minispade(content, name, msg = nil)
    assert_includes content, %Q{minispade.register('#{name}'}
  end

  private
  def compile
    TestApp.compile
  end
end

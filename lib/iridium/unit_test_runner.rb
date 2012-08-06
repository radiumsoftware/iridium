require 'pty'

module Iridium
  class UnitTestRunner
    attr_reader :app, :files, :collector

    def initialize(app, files, collector = [])
      @app, @collector = app, collector
      @files = files.collect { |f| f.gsub(%r{.coffee$}, '.js') }
    end

    def run(options = {})
      assert_files

      begin
        File.open loader_path, "w+" do |index|
          index.puts ERB.new(template_erb).result(binding)
        end

        return collector if options[:dry_run]

        js_test_runner = File.expand_path('../casperjs/qunit_runner.coffee', __FILE__)

        command_options = { 
          "index" => loader_path,
          "lib-path" => Iridium.js_lib_path,
          "test-path" => app.root.join('test')
        }

        switches = command_options.keys.map { |s| %Q{--#{s}="#{command_options[s]}"} }.join(" ")
        file_args = files.map { |f| %Q{"#{f}"} }.join(" ")

        command = %Q{casperjs "#{js_test_runner}" #{file_args} #{switches}}

        streamer = CommandStreamer.new command
        streamer.run options do |message|
          collector << TestResult.new(message)
        end
      rescue CommandStreamer::CommandFailed => ex
        result = TestResult.new :error => true
        result.name = "Javascript Execution Error"
        result.backtrace = ex.backtrace
        result.file = loader_path.to_s

        collector << result
      ensure
        FileUtils.rm loader_path if File.exists? loader_path
        return collector
      end
    end

    def loader_path
      app.site_path.join "unit_test_runner.html"
    end

    def template_erb
      template_path = app.root.join('test', 'unit', 'runner.html.erb')

      if File.exists? template_path
        File.read template_path
      else
        default_template
      end
    end

    def assert_files
      files.each do |file|
        full_path = app.root.join file
        raise "#{full_path} does not exist!" unless File.exists?(full_path)
      end
    end

    def default_template
      <<-str
      <!DOCTYPE html>
      <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Unit Tests</title>

          <!--[if lt IE 9]>
            <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
          <![endif]-->
        </head>

        <body>
          <div id="qunit"></div>
          <% app.config.dependencies.each do |script| %>
            <script src="<%= script.url %>"></script>
          <% end %>

          <script src="application.js"></script>
        </body>
      </html>
      str
    end
  end
end

module Iridium
  class UnitTestRunner
    attr_reader :app, :files

    def initialize(app, files)
      @app, @files = app, files.collect { |f| f.gsub /\.coffe$/, '.js'  }
    end

    def run(options = {})
      File.open loader_path, "w+" do |index|
        index.puts ERB.new(template_erb).result(binding)
      end

      js_test_runner = File.expand_path('../phantomjs/run-qunit.js', __FILE__)
      js_command = %Q{phantomjs "#{js_test_runner}" "#{loader_path}"}

      return if options[:dry_run]

      puts `#{js_command}`
    end

    def test_root
      app.root.join 'tmp', 'test_root'
    end

    def support_files
      Dir[test_root.join('test', 'support', "**", "*.js")].collect do |path|
        path.gsub "#{test_root.to_s}/", ''
      end
    end

    def loader_path
      test_root.join "unit_test_runner-#{Digest::MD5.hexdigest(files.to_s)}.html"
    end

    def template_erb
      template_path = app.root.join('test', 'unit', 'runner.html.erb')

      if File.exists? template_path
        File.read template_path
      else
        default_template
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

          <link href="/application.css" rel="stylesheet">
          <link href="http://code.jquery.com/qunit/qunit-1.9.0.css", rel="stylesheet">
        </head>

        <body>
          <div id="qunit"></div>
          <% app.config.dependencies.each do |script| %>
            <script src="<%= script.url %>"></script>
          <% end %>

          <% support_files.each do |file| %>
            <script src="<%= file %>"></script>
          <% end %>

          <% files.each do |file| %>
            <script src="<%= file %>"></script>
          <% end %>

          <script src="/application.js"></script>
        </body>
      </html>
      str
    end
  end
end

require 'pty'

module Iridium
  class UnitTestRunner
    attr_reader :app, :files, :collector

    def initialize(app, files, collector = [])
      @app, @files, @collector = app, files, collector
    end

    def run(options = {})
      assert_files

      File.open loader_path, "w+" do |index|
        index.puts ERB.new(template_erb).result(binding)
      end

      return [] if options[:dry_run]

      js_test_runner = File.expand_path('../phantomjs/run-qunit.js', __FILE__)
      js_command = %Q{phantomjs "#{js_test_runner}" "#{loader_path}"}

      begin
        PTY.spawn js_command do |stdin, stdout, pid|
          begin
            stdin.each do |output|
              if output =~ %r{<iridium>(.+)</iridium>}
                collector << TestResult.new(JSON.parse($1))
              elsif options[:debug]
                puts output
              end
            end
          rescue Errno::EIO
          end
        end
      rescue PTY::ChildExited
      end

      collector
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

    def assert_files
      files.each do |file|
        full_path = test_root.join file
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

          <% support_files.each do |file| %>
            <script src="<%= file %>"></script>
          <% end %>

          <% files.each do |file| %>
            <script src="<%= file %>"></script>
          <% end %>

          <script src="application.js"></script>
        </body>
      </html>
      str
    end
  end
end

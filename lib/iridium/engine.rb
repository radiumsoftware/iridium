module Iridium
  class Engine < Component
    def paths
      @paths ||= begin
        set = Hydrogen::PathSet.new root
        set[:app].add "app"

        set[:config].add "app/config"
        set[:initializers].add "app/config/initializers"
        set[:javascripts].add "app/javascripts"
        set[:stylesheets].add "app/stylesheets"
        set[:templates].add "app/templates"
        set[:assets].add "app/assets"
        set[:locales].add "app/locales"
        set[:sprites].add "app/sprites"

        set[:system_initializers].add "config/initializers", :glob => "**/*.rb"
        set[:environment].add "config", :glob => proc { "#{Iridium.env}.rb" }

        set[:settings].add "config", :glob => "**/*.yml"

        set[:vendor].add "vendor"

        set[:site].add "site"

        set[:tmp].add "tmp"
        set[:build].add "builds"
        set
      end
    end

    def app_path
      paths[:app].expanded.first
    end

    def site_path
      paths[:site].expanded.first
    end

    def vendor_path
      paths[:vendor].expanded.first
    end

    def tmp_path
      paths[:tmp].expanded.first
    end

    def build_path
      paths[:build].expanded.first
    end
  end
end

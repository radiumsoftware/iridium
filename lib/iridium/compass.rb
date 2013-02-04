module Iridium
  class CompassConfiguration < Compass::Configuration::Data
    def initialize
      super "iridium_config"
    end
  end

  class CompassComponent < Component
    config.compass = CompassConfiguration.new

    config.compass.line_comments = false

    initializer do |app|
      Compass.reset_configuration!

      app.config.compass.project_path = app.root
      app.config.compass.sprite_load_path = app.all_paths[:sprites].expanded
      app.config.compass.generated_images_path = app.site_path.join('images').to_s

      app.paths[:stylesheets].expanded.each do |path|
        app.config.compass.add_import_path path
      end

      app.paths[:vendored_stylesheets].expanded.each do |path|
        app.config.compass.add_import_path path
      end

      Compass.add_configuration app.config.compass
    end
  end
end

module Iridium
  class CompassConfiguration < Compass::Configuration::Data
    def initialize
      super "iridium_config"
    end
  end

  class CompassComponent < Component
    config.compass = CompassConfiguration.new

    config.compass.line_comments = false

    before_compile do |app|
      Compass.reset_configuration!

      app.config.compass.project_path = app.root
      app.config.compass.sprite_load_path = app.paths[:sprites].expanded
      app.config.compass.generated_images_path = app.site_path.join('images').to_s
      app.config.compass.additional_import_paths = [app.vendor_path.join("stylesheets")]

      Compass.add_configuration app.config.compass
    end
  end
end

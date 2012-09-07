module Iridium
  class CompassConfiguration < Compass::Configuration::Data
    def initialize(app)
      super "iridium_config"

      self.project_path = app.root
      self.sprite_load_path = app.app_path.join('assets', 'images', 'sprites').to_s
      self.generated_images_path = app.site_path.join('images').to_s
      self.additional_import_paths = [app.vendor_path.join("stylesheets")]
      self.line_comments = false
    end
  end
end

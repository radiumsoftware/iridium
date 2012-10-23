class TestEngine < Iridium::Engine
  def root
    Pathname.new(File.expand_path("../../app/external", __FILE__))
  end
end

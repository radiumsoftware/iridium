class TestApp < Iridium::Application
  def root
    @root ||= Pathname.new(File.dirname(__FILE__))
  end
end

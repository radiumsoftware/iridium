# This is a mock engine in the sense that it does not 
# change any state. It's rooted in a empty directory to
# not accidently add files to the pipeline

Iridium::Component::ABSTRACT_COMPONENTS << "MockEngine"

class MockEngine < Iridium::Engine
  def root
    Pathname.new(File.expand_path("../../sandbox", __FILE__))
  end
end

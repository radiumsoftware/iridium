require 'test_helper'

class IndexFileGeneratorTest < GeneratorTestCase
  def command
    Iridium::Commands::Generate
  end

  def test_generator_creates_an_index
    invoke

    assert_file 'app/public/index.html.erb'
    index_path = destination_root.join('app', 'public', 'index.html.erb')
    content = read index_path

    assert_includes content, %Q{<script src="/application.js"></script>}
    assert_includes content, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes content, %Q{minispade.require("test_app/boot");}
  end
end

require 'test_helper'
require 'iridium/commands/index_file_generator'

class IndexFileGeneratorTest < GeneratorTestCase
  def command
    Iridium::Commands::IndexFileGenerator
  end

  def test_generator_creates_an_index
    invoke :index

    assert_file 'app/public/index.html.erb'
    index_path = destination_root.join('app', 'public', 'index.html.erb')
    content = read index_path

    assert_includes content, %Q{<script src="/application.js"></script>}
    assert_includes content, %Q{<link href="/application.css" rel="stylesheet">}
    assert_includes content, %Q{minispade.require("sandbox/app");}
  end
end

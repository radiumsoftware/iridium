class GeneratorTestCase < MiniTest::Unit::TestCase
  def setup
    FileUtils.rm_rf destination_root
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def read(path)
    File.read(path)
  end

  def invoke(*args)
    options = args.extract_options!
    task_name = args.shift
    runner = command.new args, options
    runner.destination_root = destination_root
    capture(:stdout) { runner.invoke task_name }
  end

  def assert_file(*path)
    full_path = destination_root.join *path

    assert File.exists?(full_path), 
      "#{full_path} should be a file. Current Files: #{Dir[destination_root.join("**", "*").inspect]}"
  end

  def destination_root
    Pathname.new(File.expand_path('../../sandbox', __FILE__))
  end
end

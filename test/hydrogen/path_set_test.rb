require 'test_helper'
require 'fileutils'

class Hydrogen::PathSetTest < MiniTest::Unit::TestCase
  def create_file(path)
    FileUtils.mkdir_p File.dirname(sandbox_path.join(path))
    FileUtils.touch sandbox_path.join(path)
  end

  def create_directory(path)
    FileUtils.mkdir_p sandbox_path.join(path)
  end

  def test_blows_up_when_root_does_not_exist
    assert_raises Hydrogen::IncorrectRoot do
      Hydrogen::PathSet.new "/foo/bar"
    end
  end

  def test_accessing_a_new_key_returns_a_new_set
    set = Hydrogen::PathSet.new sandbox_path
    assert set[:images]
  end

  def test_paths_can_return_directories
    create_directory "images/sprites"
    create_file "logo.png"

    set = Hydrogen::PathSet.new sandbox_path
    set[:images].add "images", :glob => "*"

    directories = set[:images].directories

    assert_equal 1, directories.length
    assert_includes directories, sandbox_path.join("images/sprites").to_s
  end

  def test_paths_can_return_files
    create_file "images/logo.png"
    create_directory "images/sprites"

    set = Hydrogen::PathSet.new sandbox_path
    set[:images].add "images", :glob => "*.png"

    files = set[:images].files

    assert_equal 1, files.length
    assert_includes files, sandbox_path.join("images/logo.png").to_s
  end

  def test_paths_used_expanded_for_array
    create_file "images/logo.png"

    set = Hydrogen::PathSet.new sandbox_path
    set[:images].add "images", :glob => "*.png"

    assert_equal set[:images].expanded, set[:images].to_a
  end
end

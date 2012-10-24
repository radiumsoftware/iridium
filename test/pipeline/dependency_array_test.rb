require 'test_helper'

class DependencyArrayTest < MiniTest::Unit::TestCase
  attr_reader :deps

  def setup
    @deps = Iridium::Pipeline::DependencyArray.new
  end

  def test_load_add_dependences
    deps.load :foo

    assert_includes deps.files, :foo
  end

  def test_unload_removes_dependences
    deps << :foo
    deps.unload :foo

    assert_empty deps.files
  end

  def test_insert_after
    deps << :a
    deps << :b
    deps.insert_after :a, :c

    assert_equal [:a, :c, :b], deps.files
  end

  def test_insert_before
    deps << :a
    deps << :b
    deps.insert_before :b, :c

    assert_equal [:a, :c, :b], deps.files
  end

  def test_insert_bang_inserts_at_the_top
    deps << :a
    deps.load! :b

    assert_equal [:b, :a], deps.files
  end

  def test_swap_dependencies
    deps.load :handlebars

    deps.swap :handlebars, :handlebars_runtime

    assert_includes deps.files, :handlebars_runtime
    refute_includes deps.files, :handlebars
    assert_includes deps.skips, :handlebars
  end

  def test_swapping_in_depenencies_removes_skips
    deps.load :handlebars
    deps.skip :handlebars_runtime
    deps.swap :handlebars, :handlebars_runtime

    assert_includes deps.files, :handlebars_runtime
    refute_includes deps.skips, :handlebars_runtime
  end

  def test_files_contains_loaded_files_without_skips
    deps.load :a, :b, :c
    deps.skip :b

    assert_equal [:a, :c], deps.files
  end

  def test_loading_unskips_files
    deps.skip :a
    deps.load :a

    assert_equal [:a], deps.files
    assert_empty deps.skips
  end
end

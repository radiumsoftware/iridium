require 'test_helper'
require 'stringio'

class FinalizingFilterTest < MiniTest::Unit::TestCase
  def root
    File.expand_path("../../../", __FILE__)
  end

  def repo
    @repo ||= Grit::Repo.new root
  end

  def test_adds_the_git_sha_to_the_file
    inputs = [StringIO.new("content")]
    output = StringIO.new

    filter = Iridium::Pipeline::FinalizingFilter.new root

    filter.generate_output inputs, output

    output.rewind

    assert_includes output.read, repo.commits.first.id
  end

  def test_adds_the_commit_date
    inputs = [StringIO.new("content")]
    output = StringIO.new

    filter = Iridium::Pipeline::FinalizingFilter.new root

    filter.generate_output inputs, output

    output.rewind

    assert_includes output.read, repo.commits.first.committed_date.to_s
  end

  def test_adds_the_commit_author
    inputs = [StringIO.new("content")]
    output = StringIO.new

    filter = Iridium::Pipeline::FinalizingFilter.new root

    filter.generate_output inputs, output

    output.rewind

    assert_includes output.read, repo.commits.first.author.to_s
  end

  def test_does_not_blow_up_when_not_in_a_git_project
    inputs = [StringIO.new("content")]
    output = StringIO.new

    filter = Iridium::Pipeline::FinalizingFilter.new "/"

    filter.generate_output inputs, output

    output.rewind

    assert output.read, "Things should continue on"
  end
end

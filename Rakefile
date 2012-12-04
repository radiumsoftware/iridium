#!/usr/bin/env rake
require "bundler/gem_tasks"
require "bundler/setup"
require "coffee-script"

require 'rake/testtask'

desc "Test all internal coffeescript compiles"
task :compile do
  Dir['lib/iridium/**/*.coffee'].each do |path|
    begin
      CoffeeScript.compile File.read(path)
    rescue Exception => ex
      raise "#{path} could not be compiled! #{ex}"
    end
  end
end

namespace :test do
  desc "Run all tests"
  Rake::TestTask.new(:all => :compile) do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
  end

  desc "Runs integration tests only" 
  Rake::TestTask.new(:integration => :compile) do |test|
    test.libs << 'test'
    test.pattern = 'test/integration/**/*_test.rb'
  end

  desc "Run tests for thor commands"
  Rake::TestTask.new(:commands => :compile) do |test|
    test.libs << 'test'
    test.pattern = 'test/commands/**/*_test.rb'
  end

  desc "Run tests for the pipeline"
  Rake::TestTask.new(:pipeline) do |test|
    test.libs << 'test'
    test.pattern = 'test/integration/pipeline_test.rb'
  end

  desc "Run tests for rack related thigns"
  Rake::TestTask.new(:rack) do |test|
    test.libs << 'test'
    test.pattern = 'test/rack/**_test.rb'
  end
end

namespace :casperjs do
  iridium_root = File.expand_path '../lib/iridium/casperjs/lib', __FILE__
  test_root = File.expand_path '../fixtures/', __FILE__
  runner = File.expand_path '../lib/iridium/casperjs/test_runner.coffee', __FILE__
  loader = File.expand_path '../fixtures/blank.html', __FILE__

  desc "Runs the unit test runner aganist a local qunit test file"
  task :qunit => :compile do
    tests = File.expand_path '../fixtures/qunit_tests.js', __FILE__

    command = %Q{casperjs "#{runner}" "#{tests}" --index=#{loader} --lib-path=#{iridium_root} --test-path=#{test_root}}
    puts "Running: #{command}"
    exec command
  end

  desc "Runs the integration test runner aganist a local test file"
  task :integration => :compile do
    tests = [
      File.expand_path('../fixtures/integration/truth_test.coffee', __FILE__),
      File.expand_path('../fixtures/integration/failing_test.coffee', __FILE__)
    ].join(" ")

    command = %Q{casperjs "#{runner}" #{tests} --index=#{loader} --lib-path=#{iridium_root} --test-path=#{test_root}}
    puts "Running: #{command}"
    exec command
  end
end

task :default => 'test:all'

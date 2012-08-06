#!/usr/bin/env rake
require "bundler/gem_tasks"
require "bundler/setup"
require "coffee-script"

require 'rake/testtask'

desc "Test all internal coffeescript compiles"
task :compile do
  Dir['lib/iridium/**/*.coffee'].each do |path|
    CoffeeScript.compile File.read(path)
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

  desc "Run tests for unit test runner"
  Rake::TestTask.new(:unit_test_runner => :compile) do |test|
    test.libs << 'test'
    test.pattern = 'test/unit_test_runner_test.rb'
  end

  desc "Run tests for integration runner"
  Rake::TestTask.new(:integration_test_runner => :compile) do |test|
    test.libs << 'test'
    test.pattern = 'test/integration_test_runner_test.rb'
  end

  desc "Run tests for thor commands"
  Rake::TestTask.new(:commands => :compile) do |test|
    test.libs << 'test'
    test.pattern = 'test/commands/**/*_test.rb'
  end
end

namespace :casperjs do
  iridium_root = File.expand_path '../lib/iridium/casperjs/lib', __FILE__
  test_root = File.expand_path '../fixtures/', __FILE__

  desc "Runs the unit test runner aganist a local qunit test file"
  task :qunit => :compile do
    runner = File.expand_path '../lib/iridium/casperjs/unit_test_runner.coffee', __FILE__
    loader = File.expand_path '../fixtures/blank.html', __FILE__
    tests = File.expand_path '../fixtures/qunit_tests.js', __FILE__

    command = %Q{casperjs "#{runner}" "#{tests}"  --index=#{loader}}
    puts "Running: #{command}"
    exec command
  end

  desc "Runs the integration test runner aganist a local test file"
  task :integration => :compile do
    integration_runner = File.expand_path '../lib/iridium/casperjs/integration_test_runner.coffee', __FILE__
    test_file = File.expand_path '../fixtures/integration_test.coffee', __FILE__
    command = %Q{casperjs "#{integration_runner}" "#{test_file}" --lib-path=#{iridium_root} --test-path=#{test_root}}
    puts "Running: #{command}"
    exec command
  end
end

task :default => 'test:all'

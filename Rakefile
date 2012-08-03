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
end

namespace :casperjs do
  qunit_runner = File.expand_path '../lib/iridium/casperjs/qunit_runner.coffee', __FILE__
  iridium_root = File.expand_path '../lib/iridium/casperjs', __FILE__
  test_root = File.expand_path '../fixtures/', __FILE__

  desc "Runs the unit test runner aganist a local qunit test file"
  task :qunit => :compile do
    qunit_file = File.expand_path '../fixtures/qunit.html', __FILE__
    command = %Q{casperjs "#{qunit_runner}" "#{qunit_file}" --iridium-root="#{iridium_root}" --test-root="#{test_root}"}
    puts "Running: #{command}"
    exec command
  end
end

task :default => 'test:all'

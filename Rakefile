#!/usr/bin/env rake
require "bundler/gem_tasks"
require "bundler/setup"
require "coffee-script"

require 'rake/testtask'
Rake::TestTask.new(:test => :check_coffee_script) do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
end

desc "Test all internal coffeescript compiles"
task :check_coffee_script do
  Dir['lib/iridium/**/*.coffee'].each do |path|
    CoffeeScript.compile File.read(path)
  end
end

task :default => :test

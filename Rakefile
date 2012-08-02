#!/usr/bin/env rake
require "bundler/gem_tasks"

require 'rake/testtask'

namespace :test do
  desc "Run all tests"
  Rake::TestTask.new(:all) do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
  end

  desc "Runs integration tests only" 
  Rake::TestTask.new(:integration) do |test|
    test.libs << 'test'
    test.pattern = 'test/integration/**/*_test.rb'
  end
end

task :default => 'test:all'

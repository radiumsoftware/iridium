# -*- encoding: utf-8 -*-
require File.expand_path('../lib/iridium/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Adam Hawkins"]
  gem.email         = ["me@broadcastingdam.com"]
  gem.description   = %q{Integrated development environment for browser applications}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/radiumsoftware/iridium"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "iridium"
  gem.require_paths = ["lib"]
  gem.version       = Iridium::VERSION

  gem.add_dependency "rack"
  gem.add_dependency "rack-rewrite"
  gem.add_dependency "uglifier", "~> 1.2.3"
  gem.add_dependency "sass"
  gem.add_dependency "compass"
  gem.add_dependency "less"
  gem.add_dependency "execjs"
  gem.add_dependency "coffee-script"
  gem.add_dependency "yui-compressor"
  gem.add_dependency "rake-pipeline", "~> 0.8.0"
  gem.add_dependency "rake-pipeline-web-filters", "0.7.0"
  gem.add_dependency "activesupport"
  gem.add_dependency "thor"
  gem.add_dependency "barber", "~> 0.4.2"
  gem.add_dependency "handlebars-source", "1.0.0rc3"

  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "webmock"
end

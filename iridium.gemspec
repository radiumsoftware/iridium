# -*- encoding: utf-8 -*-
require File.expand_path('../lib/iridium/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Adam Hawkins"]
  gem.email         = ["adam@radiumcrm.com"]
  gem.description   = %q{Asset Compilation, API Proxying, and Server for Pure JS Frontends}
  gem.summary       = %q{}
  gem.homepage      = "https://github.com/radiumsoftware/iridium"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "iridium"
  gem.require_paths = ["lib"]
  gem.version       = Iridium::VERSION

  gem.add_dependency "rack"
  gem.add_dependency "thin"
  gem.add_dependency "rack-rewrite"
  gem.add_dependency "uglifier", "~> 1.2.3"
  gem.add_dependency "sass"
  gem.add_dependency "less"
  gem.add_dependency "compass"
  gem.add_dependency "coffee-script"
  gem.add_dependency "yui-compressor"
  gem.add_dependency "rake-pipeline"
  gem.add_dependency "rake-pipeline-web-filters"
end

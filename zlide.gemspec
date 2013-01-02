# -*- encoding: utf-8 -*-
require File.expand_path('../lib/zlide/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Roetzel"]
  gem.email         = ["david@roetzel.de"]
  gem.description   = %q{web-based presentation tool}
  gem.summary       = %q{web-based presentation tool}
  gem.homepage      = "https://github.com/oneiros/zlide"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "zlide"
  gem.require_paths = ["lib"]
  gem.version       = Zlide::VERSION

  gem.add_dependency 'redcarpet', '~> 2.2.2'
  gem.add_dependency 'prawn', '~> 0.12.0'
  gem.add_dependency 'thor', '~> 0.16.0'
  gem.add_dependency 'sinatra', '~> 1.3.3'
  gem.add_dependency 'haml', '~> 3.1.7'
  gem.add_dependency 'sprockets', '~> 2.8.1'
 
  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'rack-test', '~> 0.6.2'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dumagst/version'

Gem::Specification.new do |spec|
  spec.name          = "dumagst"
  spec.version       = Dumagst::VERSION
  spec.authors       = ["yurivm"]
  spec.email         = ["yuri.veremeyenko@gmail.com"]
  spec.summary       = %q{A very basic recommendation engine}
  spec.description   = %q{This should work (c)}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "jazz_hands"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.9.0"
  spec.add_development_dependency "terminal-table"
end

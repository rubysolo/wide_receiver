# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wide_receiver/version'

Gem::Specification.new do |spec|
  spec.name          = "wide_receiver"
  spec.version       = WideReceiver::VERSION
  spec.authors       = ["Solomon White"]
  spec.email         = ["rubysolo@gmail.com"]
  spec.summary       = %q{WideReceiver}
  spec.description   = %q{Message bus fanout workers}
  spec.homepage      = "https://github.com/rubysolo/wide_receiver"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry-nav"
end

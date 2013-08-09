# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "rack-redis-session-store"
  spec.version       = VERSION
  spec.authors       = ["Le Duc Duy"]
  spec.email         = ["me@duy.kr"]
  spec.description   = "Multi-threaded Redis store for rack ID-based session (connection pooled with option for maximum redis connection)"
  spec.summary       = ""
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_dependency "connection_pool"
  spec.add_dependency "redis"
  spec.add_dependency "hiredis"
  spec.add_dependency 'multi_json', '~> 1.0'
end

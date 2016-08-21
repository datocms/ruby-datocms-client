# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dato/version'

Gem::Specification.new do |spec|
  spec.name          = "dato"
  spec.version       = Dato::VERSION
  spec.authors       = ["Stefano Verna"]
  spec.email         = ["s.verna@cantierecreativo.net"]

  spec.summary       = %q{Ruby client for DatoCMS API}
  spec.description   = %q{Ruby client for DatoCMS API}
  spec.homepage      = "https://github.com/datocms/ruby-datocms-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|build|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubyzip"
  spec.add_development_dependency "json_schema"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"

  spec.add_runtime_dependency "faraday", [">= 0.9.0"]
  spec.add_runtime_dependency "faraday_middleware", [">= 0.9.0"]
  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "fastimage"
  spec.add_runtime_dependency "downloadr"
  spec.add_runtime_dependency "addressable"
end

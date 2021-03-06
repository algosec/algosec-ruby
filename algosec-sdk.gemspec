# frozen_string_literal: true

# http://guides.rubygems.org/specification-reference
require_relative './lib/algosec-sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'algosec-sdk'
  spec.version       = ALGOSEC_SDK::VERSION
  spec.authors       = ['Almog Cohen']
  spec.email         = ['almog.cohen@algosec.com']
  spec.summary       = 'Gem to interact with AlgoSec API'
  spec.description   = 'Gem to interact with AlgoSec API'
  spec.license       = 'MIT'
  spec.homepage      = 'https://github.com/algosec/algosec-ruby'

  all_files = `git ls-files -z`.split("\x0")
  spec.files         = all_files.reject { |f| f.match(%r{^(examples\/)|(spec\/)}) }
  spec.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'httpclient'
  spec.add_runtime_dependency 'ipaddress'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 0.58.2'
  spec.add_development_dependency 'simplecov'
end

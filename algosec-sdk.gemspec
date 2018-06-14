# http://guides.rubygems.org/specification-reference

# (c) Copyright 2018 AlgoSec Systems
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

require_relative './lib/algosec-sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'algosec-sdk'
  spec.version       = ALGOSEC_SDK::VERSION
  spec.authors       = ['Almog Cohen']
  spec.email         = ['almog.cohen@algosec.com']
  spec.summary       = 'Gem to interact with AlgoSec API'
  spec.description   = 'Gem to interact with AlgoSec API'
  spec.license       = 'Apache-2.0'
  spec.homepage      = 'https://github.com/algosec/algosec-sdk-ruby'

  all_files = `git ls-files -z`.split("\x0")
  spec.files         = all_files.reject { |f| f.match(%r{^(examples\/)|(spec\/)}) }
  spec.executables   = all_files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'pry'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '> 0.49.0'
  spec.add_development_dependency 'simplecov'
end

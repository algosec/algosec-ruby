require 'bundler'
require 'bundler/gem_tasks'
require 'bundler/setup'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: :test

desc 'Run unit tests only'
RSpec::Core::RakeTask.new(:spec) do |spec|
  require 'pry-byebug'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = '--color '
end

RuboCop::RakeTask.new do |task|
  task.options << '--display-cop-names'
end

desc 'Runs rubocop and unit tests'
task test: %i[rubocop spec]

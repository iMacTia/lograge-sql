# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

desc 'Run all rubocop and rspec tests'
task default: %i[spec rubocop]

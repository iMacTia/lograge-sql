# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in lograge-sql.gemspec
gemspec

install_if -> { ENV.fetch('RAILS_VERSION', nil) } do
  gem 'rails', ENV.fetch('RAILS_VERSION', nil)
end

group :development do
  gem 'base64'
  gem 'mutex_m'
  gem 'rake', '>= 12.3.3'
  gem 'rspec', '~> 3.0'
  gem 'simplecov', '~> 0.12'
end

group :linting do
  gem 'inch', '~> 0.8.0'
  gem 'rubocop-performance', '~> 1.5'
  gem 'rubocop-rails', '~> 2.7'
end

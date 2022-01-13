# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lograge/sql/version'

Gem::Specification.new do |spec|
  spec.name          = 'lograge-sql'
  spec.version       = Lograge::Sql::VERSION
  spec.authors       = ['Mattia Giuffrida']
  spec.email         = ['giuffrida.mattia@gmail.com']

  spec.summary       = 'An extension for Lograge to log SQL queries'
  spec.description   = 'An extension for Lograge to log SQL queries'
  spec.homepage      = 'https://github.com/iMacTia/lograge-sql'
  spec.license       = 'MIT'

  spec.files = Dir['lib/**/*', 'Rakefile', 'README.md']
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.add_dependency 'activerecord', '>= 5', '< 7.1'
  spec.add_dependency 'lograge', '~> 0.11'

  spec.add_development_dependency 'rake', '>= 12.3.3'
end

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lograge/sql/version'

Gem::Specification.new do |spec|
  spec.name          = 'lograge-sql'
  spec.version       = Lograge::Sql::VERSION
  spec.authors       = ['Mattia Giuffrida']
  spec.email         = ['giuffrida.mattia@gmail.com']

  spec.summary       = %q{An extension for Lograge to log SQL queries}
  spec.description   = %q{An extension for Lograge to log SQL queries}
  spec.homepage      = 'https://github.com/iMacTia/lograge-sql'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'lograge', '~> 0.4'
  spec.add_runtime_dependency 'activerecord', '>= 4', '< 6.0'

  spec.add_development_dependency 'bundler', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

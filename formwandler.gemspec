require_relative 'lib/formwandler/version'

Gem::Specification.new do |s|
  s.name = 'formwandler'
  s.version = Formwandler::VERSION
  s.summary = 'Form objects for rails'
  s.description = 'Create form objects for multiple models, dynamically mark fields as hidden or disabled and even hide select options dynamically'
  s.homepage = 'https://github.com/sbilharz/formwandler'
  s.files = Dir['lib/**/*.rb']
  s.authors = ['Stefan Bilharz']
  s.email = 'sbilharz@heilmannsoftware.de'
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.3'

  s.add_runtime_dependency 'rails', '>= 5.0.0'
  s.add_runtime_dependency 'delocalize', '~> 1.2'

  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-rails', '~> 3'
  s.add_development_dependency 'rails-controller-testing', '~> 1'
  s.add_development_dependency 'sqlite3', '~> 1.3.6'
  s.add_development_dependency 'byebug', '~> 9.1'
end

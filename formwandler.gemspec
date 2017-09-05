Gem::Specification.new do |s|
  s.name = 'formwandler'
  s.version = '0.0.1'
  s.summary = 'Form objects for rails'
  s.description = 'Create form objects for multiple models, dynamically mark fields as hidden or disabled and even hide select options dynamically'
  s.files = ['lib/formwandler.rb', 'lib/formwandler/form.rb', 'lib/formwandler/field_definition.rb', 'lib/formwandler/field.rb']
  s.authors = ['Stefan Bilharz']
  s.email = 'sbilharz@heilmannsoftware.de'
  s.license = 'MIT'

  s.required_ruby_version = '>= 2.3'

  s.add_dependency 'rails', '~> 5.0'
end

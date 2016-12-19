Gem::Specification.new do |s|
  s.name        = 'aasm_statecharts'
  s.version     = '1.0.2'
  s.date        = '2016-12-18'
  s.summary     = "AASM statecharts"
  s.description = "Generate UML-style state charts from AASM state machines"
  s.authors     = ["Brendan MacDonell", "Ashley Engelund"]
  s.email       = ['brendan@macdonell.net', 'ashley@ashleycaroline.com']
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.executables = ['aasm_statecharts']
  s.homepage    = 'http://rubygems.org/gems/aasm_statecharts'
  s.license     = 'MIT'

  s.add_dependency 'rails', '~> 5.0'
  s.add_dependency 'aasm', '~> 3.0'
  s.add_dependency 'ruby-graphviz', '~> 1.0'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

end

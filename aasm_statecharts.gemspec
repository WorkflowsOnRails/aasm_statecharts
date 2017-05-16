Gem::Specification.new do |s|
  s.name        = 'aasm_statecharts'
  s.version     = '1.0.0'
  s.date        = '2014-01-18'
  s.summary     = "AASM statecharts"
  s.description = "Generate UML-style state charts from AASM state machines"
  s.authors     = ["Brendan MacDonell"]
  s.email       = 'brendan@macdonell.net'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(README.md)
  s.executables = ['aasm_statecharts']
  s.homepage    = 'http://rubygems.org/gems/aasm_statecharts'
  s.license     = 'MIT'

  s.add_runtime_dependency 'rails', ['>= 4.0']
  s.add_runtime_dependency 'aasm', ['>= 3.0']
  s.add_runtime_dependency 'ruby-graphviz', ['~> 1.0']
end

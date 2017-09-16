require File.join(__dir__, 'lib','aasm-statecharts', 'version')

Gem::Specification.new do |s|
  s.name        = 'aasm_statecharts'
  s.version     = AASM_StateChart::VERSION
  s.date        = '2017-09-12'
  s.summary     = "AASM statecharts"
  s.description = "Uses ruby-graphviz to create a graph from AASM state machine code. This gem creates a .dot file, which is then used by ruby-graphviz to call graphviz dot to create a graphic (e.g. .png) file.  This assumes you have graphviz installed and on your PATH.  Based on Brendan MacDonell's AASM statecharts gem."
  s.authors     = ["Ashley Engelund"]
  s.email       = ['ashley@ashleycaroline.com']

  s.files       = Dir.glob("#{File.join('lib', '**', '*')}") + ['bin/aasm_statecharts'] + %w(README.md LICENSE.txt blue_config_example.yml)
  s.executables = ['aasm_statecharts']

  s.homepage    = 'http://rubygems.org/gems/aasm_statecharts'
  s.license     = 'MIT'

  s.add_dependency 'rails', '>= 4.0'
  s.add_dependency 'aasm', '>= 4.0'
  s.add_dependency 'ruby-graphviz', '>= 1.0'
  s.add_dependency 'psych', '>= 2.0'          # for parsing config .yml files

  s.add_development_dependency 'rspec', '>= 3.0', '>= 3.0'
  s.add_development_dependency 'simplecov', '>= 0.10', '>= 0.10'
  s.add_development_dependency 'rake'


end

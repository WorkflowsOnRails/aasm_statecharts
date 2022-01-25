# -*- encoding: utf-8 -*-
# stub: aasm_statecharts 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "aasm_statecharts".freeze
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Brendan MacDonell".freeze]
  s.date = "2014-01-18"
  s.description = "Generate UML-style state charts from AASM state machines".freeze
  s.email = "brendan@macdonell.net".freeze
  s.executables = ["aasm_statecharts".freeze]
  s.files = ["README.md".freeze, "bin/aasm_statecharts".freeze, "lib/aasm_statechart.rb".freeze]
  s.homepage = "http://rubygems.org/gems/aasm_statecharts".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.25".freeze
  s.summary = "AASM statecharts".freeze

  s.installed_by_version = "3.2.25" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, ["~> 6.1"])
    s.add_runtime_dependency(%q<aasm>.freeze, ["~> 5.1"])
    s.add_runtime_dependency(%q<ruby-graphviz>.freeze, ["~> 1.0"])
  else
    s.add_dependency(%q<rails>.freeze, ["~> 6.1"])
    s.add_dependency(%q<aasm>.freeze, ["~> 5.1"])
    s.add_dependency(%q<ruby-graphviz>.freeze, ["~> 1.0"])
  end
end

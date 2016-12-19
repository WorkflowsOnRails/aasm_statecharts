# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell

require 'spec_helper'

require 'aasm'
require 'active_record'

require 'tmpdir'
require 'fileutils'

class NoAasm
end

class EmptyAasm < ActiveRecord::Base
  include AASM
end

class SingleState < ActiveRecord::Base
  include AASM

  aasm do
    state :single,
      initial: true,
      enter: [:foo, :bar],
      exit: [:baz, :quux]
  end
end

class ManyStates < ActiveRecord::Base
  include AASM

  aasm do
    state :a, initial: true, exit: :a_exit
    state :b, enter: :b_enter
    state :c, final: true

    event :x do
      transitions from: :a, to: :a, guard: :x_guard
      transitions from: :b, to: :c
    end

    event :y do
      transitions from: :a, to: :b, on_transition: :y_action
    end

    event :z do
      transitions from: :b, to: :a, on_transition: [:z1, :z2]
    end
  end
end


describe AasmStatechart do
  include SpecHelper

  it 'fails when given a class that does not have aasm included' do
    expect { AasmStatechart::Renderer.new(NoAasm) }.to raise_error
  end

  it 'fails when given a class that has no states defined' do
    expect { AasmStatechart::Renderer.new(EmptyAasm) }.to raise_error
  end

  it 'fails if an invalid file format is given' do
    renderer = AasmStatechart::Renderer.new(SingleState)

    Dir.mktmpdir do |dir|
      filename = "#{dir}/single.png"
      expect { renderer.save(filename, format: 'foobar') }.to raise_error
    end
  end

  it 'renders statecharts with single states' do
    renderer = AasmStatechart::Renderer.new(SingleState)
    edges = renderer.graph.each_edge
    nodes = renderer.graph.each_node

    expect(edges.length).to equal 1
    expect(nodes.length).to equal 2

    expect(name_of(edges[0].node_one)).to eq name_of(renderer.start_node.id)
    expect(edges[0].node_two).to eq "single"

    expect_label_matches(nodes['single'], /entry \/ foo\(\); bar\(\);/)
    expect_label_matches(nodes['single'], /exit \/ baz\(\); quux\(\);/)

    Dir.mktmpdir do |dir|
      filename = "#{dir}/single.png"
      FileUtils.touch(filename)
      renderer.save(filename, format: 'png')
      expect(File.exists?(filename)).to be true
    end
  end

  it 'renders statecharts of arbitrary complexity' do
    renderer = AasmStatechart::Renderer.new(ManyStates)

    edges = renderer.graph.each_edge
    nodes = renderer.graph.each_node

    expect(edges.length).to equal 6
    expect(nodes.length).to equal 5

    find_edge(edges, renderer.start_node.id, 'a')
    find_edge(edges, 'c', renderer.end_node.id)

    a_a = find_edge(edges, 'a', 'a')
    expect_label_matches(a_a, /x \[x_guard\]/)

    a_b = find_edge(edges, 'a', 'b')
    expect_label_matches(a_b, /y \/ y_action\(\);/)

    b_a = find_edge(edges, 'b', 'a')
    expect_label_matches(b_a, /z \/ z1\(\); z2\(\);/)

    b_c = find_edge(edges, 'b', 'c')
    expect_label_matches(b_c, /x/)

    expect_label_matches(nodes['a'], /exit \/ a_exit/)
    expect_label_matches(nodes['b'], /entry \/ b_enter/)

    Dir.mktmpdir do |dir|
      filename = "#{dir}/many.png"
      renderer.save(filename, format: 'png')
      expect(File.exists?(filename)).to be true
    end
  end
end

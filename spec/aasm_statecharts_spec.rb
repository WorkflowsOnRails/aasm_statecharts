#
#
# @author Brendan MacDonell

require 'spec_helper'

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

def name_of(s)
  s.gsub(/\A"|"\Z/, '')
end

describe AasmStatechart do
  it 'fails when given a class that does not have aasm included' do
    expect { AasmStatechart::Renderer.new(NoAasm) }.to raise_error
  end

  it 'fails when given a class that has no states defined' do
    expect { AasmStatechart::Renderer.new(EmptyAasm) }.to raise_error
  end

  it 'renders statecharts with single states' do
    renderer = AasmStatechart::Renderer.new(SingleState)
    edges = renderer.graph.each_edge
    nodes = renderer.graph.each_node

    expect(edges.length).to equal 1
    expect(name_of(edges[0].node_one)).to eq name_of(renderer.start_node.id)
    expect(edges[0].node_two).to eq "single"

    expect(nodes['single']['label'].source).to match(/entry \/ foo\(\); bar\(\);/)
    expect(nodes['single']['label'].source).to match(/exit \/ baz\(\); quux\(\);/)
  end
end

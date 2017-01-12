# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'

require 'statechart_helper'


require 'tmpdir'
require 'fileutils'

OUT_DIR = './spec-out'

describe AASM_StateChart do
  include SpecHelper

  Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


  it 'warns when given a class that does not have aasm included' do
    expect{AASM_StateChart::Renderer.new(NoAasm)}.to raise_error(AASM_StateChart::NoAASM_Error)
  end

  it 'warns when given a class that has no states defined' do
    expect{AASM_StateChart::Renderer.new(EmptyAasm)}.to raise_error(AASM_StateChart::NoStates_Error)
  end

  it 'fails if an invalid file format is given' do
    renderer = AASM_StateChart::Renderer.new(SingleState)

    #Dir.mktmpdir do |dir|
      filename = "#{OUT_DIR}/single.png"
      expect { renderer.save(filename, format: 'foobar') }.to raise_error StandardError
    #end
  end

  it 'renders statecharts with single states' do
    renderer = AASM_StateChart::Renderer.new(SingleState)
    edges = renderer.graph.each_edge
    nodes = renderer.graph.each_node

    expect(edges.length).to eq 1
    expect(nodes.length).to eq 2

    expect(name_of(edges[0].node_one)).to eq name_of(renderer.start_node.id)
    expect(edges[0].node_two).to eq "single"

    expect_label_matches(nodes['single'], /entry \/ foo\(\); bar\(\);/)
    expect_label_matches(nodes['single'], /exit \/ baz\(\); quux\(\);/)

  #  Dir.mktmpdir do |dir|
      filename = "#{OUT_DIR}/single.png"
      FileUtils.touch(filename)
      renderer.save(filename, format: 'png')
      expect(File.exists?(filename)).to be true
  #  end
  end


  describe 'renders the claim model ' do
    let(:renderer) { AASM_StateChart::Renderer.new(Claim) }

    describe 'edges' do

      let(:edges) { renderer.graph.each_edge }

      it 'length' do
        expect(edges.length).to eq 5
      end


    end

    describe 'nodes' do
      let(:nodes) { renderer.graph.each_node }

      it 'length' do
        expect(nodes.length).to eq 5
      end

    end


    it 'can save to .png' do

     # Dir.mktmpdir do |dir|
        filename = "#{OUT_DIR}/claim.png"
        renderer.save(filename, format: 'png')
        expect(File.exists?(filename)).to be true
     # end

    end

  end


  describe 'renders many states ' do
    let(:renderer) { AASM_StateChart::Renderer.new(ManyStates, true) }

    describe 'edges' do

      let(:edges) { renderer.graph.each_edge }

      it 'length' do
        expect(edges.length).to eq 8
      end

      describe 'finds edges' do

        it 'a to a' do
          find_edge(edges, renderer.start_node.id, 'a')

          a_a = find_edge(edges, 'a', 'a')
          expect_label_matches(a_a, /x \[x_guard\]/)
        end

        it 'a to b' do
          a_b = find_edge(edges, 'a', 'b')
          expect(a_b['label'].source.strip).to eq 'y  / y_action();'
        end

        it 'b to a' do
          b_a = find_edge(edges, 'b', 'a')
          expect(b_a['label'].source.strip).to eq 'z  / z1(); z2();'
        end

        it 'b to c' do
          find_edge(edges, 'c', renderer.end_node.id)
          b_c = find_edge(edges, 'b', 'c')
          expect_label_matches(b_c, /x/)
        end
      end

    end

    describe 'nodes' do
      let(:nodes) { renderer.graph.each_node }

      it 'length' do
        expect(nodes.length).to eq 7
      end

      it 'node a label' do
        expect_label_matches(nodes['a'], /exit \/ a_exit/)
      end

      it 'node b label' do
        expect_label_matches(nodes['b'], /entry \/ b_enter/)
      end

    end


    it 'can save to .png' do

      # Dir.mktmpdir do |dir|
      filename = "#{OUT_DIR}/many.png"
      renderer.save(filename, format: 'png')
      expect(File.exists?(filename)).to be true
      # end

    end

  end
end

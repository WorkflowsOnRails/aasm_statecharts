# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'



RSpec.shared_examples 'saves to a file' do |aasm_model, output_format|
  renderer = AASM_StateChart::Chart_Renderer.new(aasm_model)

  it "can save to a #{output_format} file" do
    filename = "#{OUT_DIR}/#{aasm_model.name.underscore}.#{output_format}"
    renderer.save(filename, format: output_format)
    expect(File.exists?(filename)).to be true
  end
end


RSpec.shared_examples 'it has this many edges' do |renderer, num_edges|
  it "#{num_edges} edges" do
    expect(renderer.graph.each_edge.length).to eq num_edges
  end
end


RSpec.shared_examples 'it has this many nodes' do |renderer, num_nodes|
  it "#{num_nodes} nodes" do
    expect(renderer.graph.each_node.length).to eq num_nodes
  end
end


describe AASM_StateChart::Chart_Renderer do

  include GraphvizSpecHelper


  describe 'basic tests with single state example' do

    require_relative '../spec/fixtures/no_rails_single_state'

    renderer = AASM_StateChart::Chart_Renderer.new(NoRailsSingleState)

    it 'the single state example' do

      nodes = renderer.graph.each_node

      expect_label_matches(nodes['single'], /entry: foo bar/)
      expect_label_matches(nodes['single'], /exit: baz quux/)

    end

    it_should_behave_like 'it has this many nodes', renderer, 4

    describe 'edges' do

      it_should_behave_like 'it has this many edges', renderer, 1

      it 'finds edges' do
        edges = renderer.graph.each_edge

        expect(name_of(edges[0].node_one)).to eq name_of(renderer.start_node.id)
        expect(edges[0].node_two).to eq "single"
      end
    end

    it_should_behave_like 'saves to a file', NoRailsSingleState, 'png'

  end

  describe 'the no_rails_claim model example' do

    require_relative '../spec/fixtures/no_rails_claim'

    renderer = AASM_StateChart::Chart_Renderer.new(NoRailsClaim)

    it_should_behave_like 'it has this many edges', renderer, 5

    it_should_behave_like 'it has this many nodes', renderer, 7

    it_should_behave_like 'saves to a file', NoRailsClaim, 'jpg'

  end


  describe 'two simple states example' do

    require_relative '../spec/fixtures/no_rails_two_simple_states'

    renderer = AASM_StateChart::Chart_Renderer.new(NoRailsTwoSimpleStates)

    it_should_behave_like 'it has this many edges', renderer, 3

    it_should_behave_like 'it has this many nodes', renderer, 5

    it_should_behave_like 'saves to a file', NoRailsTwoSimpleStates, 'png'

  end


  # TODO output to a dot file and check that

  describe 'many states example' do

    require_relative '../spec/fixtures/no_rails_many_states'

    renderer = AASM_StateChart::Chart_Renderer.new(NoRailsManyStates, true)

    describe 'formatting' do

    end

    describe 'guards' do
      it 'finds a single guard: :item' do
        pending
      end

      it 'finds an array of guards: [:g1, :g2]' do
        pending
      end

      it 'finds guards using if: if_condition' do
        pending
      end

    end

    describe 'method callbacks' do

      it 'enter method ' do

      end

      it 'after methods' do

      end

      it 'before methods' do

      end
    end


    describe 'edges' do

      let(:edges) { renderer.graph.each_edge }

      it_should_behave_like 'it has this many edges', renderer, 8

      describe 'finds edges' do

        it 'a to a' do
          find_edge(edges, renderer.start_node.id, 'a')

          a_a = find_edge(edges, 'a', 'a')
          expect_label_matches(a_a, /x \[xa_guard\]/)
        end

        it 'a to b' do
          a_b = find_edge(edges, 'a', 'b')
          expect(a_b['label'].source.strip).to eq 'y  / y_before y_after'
        end

        it 'b to a' do
          b_a = find_edge(edges, 'b', 'a')
          expect(b_a['label'].source.strip).to eq 'z  / z1_before z2_before z1_after z2_after'
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

      it_should_behave_like 'it has this many nodes', renderer, 8

      it 'node a label' do
        expect_label_matches(nodes['a'], /exit: a_exit/)
      end

      it 'node b label' do
        expect_label_matches(nodes['b'], /\{B|entry: b1_enter b2_enter\\lexit: b1_exit b2_exit}/)
      end

    end

    it_should_behave_like 'saves to a file', NoRailsManyStates, 'dot'

  end
end

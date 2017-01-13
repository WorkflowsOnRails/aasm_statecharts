# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'
require 'statechart_helper'


OUT_DIR = './spec/spec-out'


RSpec.shared_examples 'saves to a file' do |aasm_model, output_format|
  renderer = AASM_StateChart::Renderer.new(aasm_model)

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



describe AASM_StateChart do
  include SpecHelper

  Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


  it 'warns when given a class that does not have aasm included' do
    expect { AASM_StateChart::Renderer.new(NoAasm) }.to raise_error(AASM_StateChart::NoAASM_Error)
  end

  it 'warns when given a class that has no states defined' do
    expect { AASM_StateChart::Renderer.new(EmptyAasm) }.to raise_error(AASM_StateChart::NoStates_Error)
  end

  it 'fails if an invalid file format is given' do
    renderer = AASM_StateChart::Renderer.new(SingleState)
    filename = "#{OUT_DIR}/single.png"
    expect { renderer.save(filename, format: 'foobar') }.to raise_error StandardError
  end


  describe 'basic tests with single state example' do

    renderer = AASM_StateChart::Renderer.new(SingleState)

    it 'the single state example' do

      nodes = renderer.graph.each_node

      expect_label_matches(nodes['single'], /entry \/ foo\(\); bar\(\);/)
      expect_label_matches(nodes['single'], /exit \/ baz\(\); quux\(\);/)

    end

    it_should_behave_like 'it has this many nodes', renderer, 2

    describe 'edges' do

      it_should_behave_like 'it has this many edges', renderer, 1

      it 'finds edges' do
        edges = renderer.graph.each_edge

        expect(name_of(edges[0].node_one)).to eq name_of(renderer.start_node.id)
        expect(edges[0].node_two).to eq "single"
      end
    end

    it_should_behave_like 'saves to a file', SingleState, 'png'

  end

  describe 'the claim model example' do
    renderer = AASM_StateChart::Renderer.new(Claim)

    it_should_behave_like 'it has this many edges', renderer, 5

    it_should_behave_like 'it has this many nodes', renderer, 5

    it_should_behave_like 'saves to a file', Claim, 'jpg'

  end


  describe 'two simple states example' do
    renderer = AASM_StateChart::Renderer.new(TwoSimpleStates)

    it_should_behave_like 'it has this many edges', renderer, 3

    it_should_behave_like 'it has this many nodes', renderer, 3

    it_should_behave_like 'saves to a file', TwoSimpleStates, 'png'

  end


  # TODO output to a dot file and check that
  describe 'many states example' do
    renderer = AASM_StateChart::Renderer.new(ManyStates, true)

    describe 'formatting' do

    end

    describe 'guards' do
      it 'finds a single guard: :item' do

      end

      it 'finds an array of guards: [:g1, :g2]' do

      end

      it 'finds guards using if: if_condition' do

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
          expect(a_b['label'].source.strip).to eq 'y  / y_before(); y_after();'
        end

        it 'b to a' do
          b_a = find_edge(edges, 'b', 'a')
          expect(b_a['label'].source.strip).to eq 'z  / z1_before(); z2_before(); z1_after(); z2_after();'
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

      it_should_behave_like 'it has this many nodes', renderer, 6

      it 'node a label' do
        expect_label_matches(nodes['a'], /exit \/ a_exit/)
      end

      it 'node b label' do
        expect_label_matches(nodes['b'], /\{B|entry \/ b1_enter(); b2_enter();\\lexit \/ b1_exit(); b2_exit();}/)
      end

    end

    it_should_behave_like 'saves to a file', ManyStates, 'dot'

  end
end

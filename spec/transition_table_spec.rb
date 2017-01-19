#--------------------------
#
# @file transition_table_spec.rb
#
# @desc Description
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   1/11/17
#
#
#--------------------------


require 'spec_helper'

RSpec.shared_examples 'the rendered output matches' do | desc, example_aasm_class, expected_str |
  let(:ttable_render) { renderer = AASM_StateChart::Chart_Renderer.new(example_aasm_class, true)
  renderer.transition_table.render }
  it "#{desc}" do
    expect(ttable_render).to match(/#{Regexp.escape(expected_str)}/)
  end
end

RSpec.shared_examples 'rendered table matches' do | desc, example_aasm_class, start, table_body, ending|
  let(:ttable_render) { renderer = AASM_StateChart::Chart_Renderer.new(example_aasm_class, true)
                 renderer.transition_table.render }

  it "#{desc}" do
    expect(ttable_render).to match(/#{Regexp.escape(start + table_body + ending)}/)
  end

end


describe AASM_StateChart::TransitionTable do

  table_start = '<<TABLE CELLPADDING="2" CELLSPACING="0" TITLE="State Transition Table"><TR><TD>Triggering Event</TD><TD>Old State</TD><TD>New State</TD><TD>Iff All These Are True</TD></TR>'
  table_end = '</TABLE>>'

  describe 'common to all' do
    it_should_behave_like 'the rendered output matches', '<TABLE...>, header row', SingleState, table_start
    it_should_behave_like 'the rendered output matches', '</TABLE...> ending', SingleState, table_end
  end


  describe 'no transitions for the single states example' do
    it_should_behave_like 'rendered table matches', 'no body rows (just header and ending)', SingleState, table_start, '', table_end
  end


  describe 'the two simple states example' do
    table_body = ''
    table_body << '<TR><TD>from_1_to_2</TD><TD>first</TD><TD>second</TD><TD>forwards_is_allowed</TD></TR>'
    table_body << '<TR><TD>from_2_to_1</TD><TD>second</TD><TD>first</TD><TD>backwards_is_allowed</TD></TR>'

    it_should_behave_like 'rendered table matches', 'two simple events', TwoSimpleStates, table_start, table_body, table_end

  end


  describe 'many states example' do
    table_body = ''
    table_body << '<TR><TD>x</TD><TD>a</TD><TD>a</TD><TD>xa_guard</TD></TR>'
    table_body << '<TR><TD>x</TD><TD>b</TD><TD>c</TD><TD>xbc1_guard xbc2_guard</TD></TR>'

    table_body << '<TR><TD>y</TD><TD>a</TD><TD>b</TD><TD>y_is_ok?</TD></TR>'

    table_body << '<TR><TD>z</TD><TD>b</TD><TD>a</TD><TD>z_is_ok? z_is_really_ok?</TD></TR>'

    table_body << '<TR><TD>many_from</TD><TD>a</TD><TD>c</TD><TD>many_guard1 many_guard2</TD></TR>'
    table_body << '<TR><TD>many_from</TD><TD>b</TD><TD>c</TD><TD>many_guard1 many_guard2</TD></TR>'

    it_should_behave_like 'rendered table matches', 'many events with guards', ManyStates, table_start, table_body, table_end

  end


end


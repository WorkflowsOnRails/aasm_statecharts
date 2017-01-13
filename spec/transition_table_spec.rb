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


RSpec.shared_examples 'a correct HTML table renderer' do | example_aasm_class, result |
  let(:ttable) {  renderer = AASM_StateChart::Renderer.new(example_aasm_class, true)
  renderer.transition_table}

  it 'creates the correct HTML table' do
    expect(ttable.render).to eq(result)
  end

end



describe AASM_StateChart::TransitionTable do

  describe 'creates a state transition table' do


    describe 'no transitions for the single states example' do

      result = ''
      result << '<<TABLE CELLPADDING="2" CELLSPACING="0" TITLE="State Transition Table"><TR><TD>Old State</TD><TD>New State</TD><TD>Triggering Event</TD><TD>Only If All These Are True</TD></TR>'
      result << '</TABLE>>'

      it_should_behave_like 'a correct HTML table renderer', SingleState, result

    end



    describe 'the two simple states example' do

      result = ''
      result << '<<TABLE CELLPADDING="2" CELLSPACING="0" TITLE="State Transition Table"><TR><TD>Old State</TD><TD>New State</TD><TD>Triggering Event</TD><TD>Only If All These Are True</TD></TR>'
      result << '<TR><TD>first</TD><TD>second</TD><TD>from_1_to_2</TD><TD>forwards_is_allowed</TD></TR>'
      result << '<TR><TD>second</TD><TD>first</TD><TD>from_2_to_1</TD><TD>backwards_is_allowed</TD></TR>'
      result << '</TABLE>>'

      it_should_behave_like 'a correct HTML table renderer', TwoSimpleStates, result

    end


    describe 'many states example' do

      result = ''
      result << '<<TABLE CELLPADDING="2" CELLSPACING="0" TITLE="State Transition Table"><TR><TD>Old State</TD><TD>New State</TD><TD>Triggering Event</TD><TD>Only If All These Are True</TD></TR>'

      result << '<TR><TD>a</TD><TD>a</TD><TD>x</TD><TD>xa_guard</TD></TR>'
      result << '<TR><TD>b</TD><TD>c</TD><TD>x</TD><TD>xbc1_guard xbc2_guard</TD></TR>'

      result << '<TR><TD>a</TD><TD>b</TD><TD>y</TD><TD>y_is_ok?</TD></TR>'

      result << '<TR><TD>b</TD><TD>a</TD><TD>z</TD><TD>z_is_ok? z_is_really_ok?</TD></TR>'

      result << '<TR><TD>a</TD><TD>c</TD><TD>many_from</TD><TD>many_guard1 many_guard2</TD></TR>'
      result << '<TR><TD>b</TD><TD>c</TD><TD>many_from</TD><TD>many_guard1 many_guard2</TD></TR>'
      result << '</TABLE>>'

      it_should_behave_like 'a correct HTML table renderer', ManyStates, result

    end
  end

end


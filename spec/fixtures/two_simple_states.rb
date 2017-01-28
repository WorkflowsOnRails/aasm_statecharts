require 'aasm'

class TwoSimpleStates < ActiveRecord::Base
  include AASM

  aasm do
    state :first,
          initial: true
    state :second


    event :from_1_to_2 do
      transitions from: :first, to: :second, if: :forwards_is_allowed
    end

    event :from_2_to_1 do
      transitions from: :second, to: :first, guard: :backwards_is_allowed
    end

  end
end
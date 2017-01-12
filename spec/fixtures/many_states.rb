require 'aasm'

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
      transitions from: :a, to: :b, after: :y_action
    end

    event :z do
      transitions from: :b, to: :a, after: [:z1, :z2]
    end

    event :many_from do
      transitions from: [:a, :b], to: :z
    end

  end
end

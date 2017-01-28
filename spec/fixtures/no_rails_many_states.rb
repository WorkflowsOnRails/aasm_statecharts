require 'aasm'

class NoRailsManyStates
  include AASM

  aasm do
    state :a, initial: true, enter: :a_enter, exit: :a_exit
    state :b, enter: [:b1_enter, :b2_enter],
              exit: [:b1_exit, :b2_exit]
    state :c, final: true

    event :x do
      transitions from: :a, to: :a, guard: :xa_guard
      transitions from: :b, to: :c, guard: [:xbc1_guard, :xbc2_guard]
    end

    event :y do
      transitions from: :a, to: :b, before: :y_before, after: :y_after, if: :y_is_ok?
    end

    event :z do
      transitions from: :b, to: :a, before: [:z1_before, :z2_before], after: [:z1_after, :z2_after], if: [:z_is_ok?, :z_is_really_ok?]
    end

    event :many_from do
      transitions from: [:a, :b], to: :c, guard: [:many_guard1, :many_guard2]
    end

  end
end

require 'aasm'

class NoRailsSingleState
  include AASM

  aasm do
    state :single,
          initial: true,
          enter: [:foo, :bar],
          exit: [:baz, :quux]
  end
end
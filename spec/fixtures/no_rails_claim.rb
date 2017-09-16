require 'aasm'

class NoRailsClaim

  include AASM

  aasm do
    state :unsubmitted, initial: true
    state :submitted, exit: [:cancel_deadline, :close_ticket]
    state :resolved, final: true

    event :submit do
      transitions from: :unsubmitted, to: :submitted,
                  guard: :accepting_claims?,
                  after: :notify_submitted
    end
    event :return do
      transitions from: :submitted, to: :unsubmitted
    end
    event :accept do
      transitions from: :submitted, to: :resolved
    end
  end

  def accepting_claims?
  end

  def cancel_deadline
  end

  def close_ticket
  end

  def notify_submitted
  end
end


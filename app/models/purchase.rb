require 'aasm'

class Purchase

  attr :amount, :name, :date

  include AASM


  aasm :column => 'state' do

    state :new, :initial => true
    state :under_review
    state :waiting_for_applicant
    state :ready_for_review
    state :accepted
    state :rejected


    event :start_review do
      transitions from: :new, to: :under_review, guard: :not_a_member?
      transitions from: :ready_for_review, to: :under_review
    end

    event :ask_applicant_for_info do
      transitions from: :under_review, to: :waiting_for_applicant
    end

    event :cancel_waiting_for_applicant do
      transitions from: :waiting_for_applicant, to: :under_review
    end

    event :is_ready_for_review do
      transitions from: :waiting_for_applicant, to: :ready_for_review
    end

    event :accept do
      transitions from: [:under_review, :rejected], to: :accepted, guard: [:paid?, :not_a_member?], after: :accept_membership
    end

    event :reject do
      transitions from: [:under_review, :accepted], to: :rejected, after: :reject_membership
    end

  end

end

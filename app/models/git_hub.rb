require 'aasm'

class GitHub < ActiveRecord::Base

  include AASM

  aasm do

    state :opened, initial: true
    state :wip
    state :needs_review
    state :failed_build
    state :successful_build
    state :review_requests_changes
    state :branch_needs_resolving
    state :ready_to_merge
    state :merged, final: true
    state :closed


    event :start_work do
      transitions from: :opened, to: :wip
    end

    event :build_succeeded do
      transitions from: [:wip ], to: :successful_build
    end

    event :build_failed do
      transitions from: [:wip], to: :failed_build
    end

    event :revise do
      transitions from: [:review_requests_changes, :failed_build], to: :wip
    end

    event :ready_for_review do
      transitions from: :successful_build, to: :needs_review
    end

    event :approved_review do
      transitions from: :needs_review, to: :ready_to_merge
    end

    event :reviewer_requests_changes do
      transitions from: :needs_review, to: :review_requests_changes
    end

    event :merged_ok do
      transitions from: :ready_to_merge, to: :merged
    end

    event :merge_failed do
      transitions from: :ready_to_merge, to: :branch_needs_resolving
    end

    event :resolve_branch do
      transitions from: :branch_needs_resolving, to: :ready_to_merge
    end

    event :close_without_merging do
      transitions from: [:opened, :wip, :needs_review,  :failed_build, :successful_build, :review_requests_changes, :branch_needs_resolving, :ready_to_merge], to: :closed
    end
  end


end

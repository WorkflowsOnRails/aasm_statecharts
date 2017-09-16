require 'aasm'

class PivotalTrackerFeature #< ActiveRecord::Base

  include AASM

  # accepted = works on heroku, verified by client if it is 'client facing' otherwise Susanna verifies it


  aasm do

    state :new_in_icebox, initial: true

    state :points_assigned

    state :started, enter: :write_feature_or_spec, exit: :all_tests_pass
    state :waiting_for_scrum_review

    state :waiting_for_client_review, enter: :press_FINISHED_button
    state :waiting_for_shf_review, enter: :press_FINISHED_button

    state :accepted, enter: :press_Accepted_button
    state :declined, enter: :press_Rejected_button

    state :delivered, enter: [ :press_DELIVERED_button, :deployed_to_PRODUCTION ], final: true


    # - - - - - - - - - - - - - - - -

    event :vote_on_feature do
      transitions from: :new_in_icebox, to: :points_assigned, guard: :at_least_3_people_voted
    end

    event :start_work do
      transitions from: :points_assigned, to: :started

    end

    event :finished_PR do
      transitions from: :started, to: :waiting_for_scrum_review
    end

    event :approved_in_scrum do
      transitions from: :waiting_for_scrum_review, to: :waiting_for_client_review, guard: :is_client_facing
      transitions from: :waiting_for_scrum_review, to: :waiting_for_shf_review, guard: :is_not_client_facing
    end

    event :rejected_in_scrum do
      transitions from: :waiting_for_scrum_review, to: :started
    end

    event :deliver_to_and_review_with_client do

    end


    event :client_accepted do
      transitions from: :waiting_for_client_review, to: :accepted, guard: :client_test_on_deployment_server_passes
    end

    event :client_rejected do
      transitions from: :waiting_for_client_review, to: :declined, guard: :client_test_on_deployment_server_fails
    end


    event :shf_accepted do
      transitions from: :waiting_for_shf_review, to: :accepted, guard: :shf_test_on_deployment_server_passes
    end

    event :shf_rejected do
      transitions from: :waiting_for_shf_review, to: :declined, guard: :shf_test_on_deployment_server_fails
    end



    event :deliver do
      transitions from: :accepted, to: :delivered
    end

  end


  def test_in_deployment_version

  end



end

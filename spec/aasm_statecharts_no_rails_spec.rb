# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'


#- - - - - - - - - -

describe AASM_StateChart::AASM_StateCharts do


  describe 'rails class' do

    describe 'no rails = true' do

      it_will 'not raise an error', "simple model isn't ActiveRecord::Base subclass so Rails isn't needed",
              good_options.update({models: ['not_rails_subclass_two_simple_states']}).update({no_rails: true})

      it_will 'not raise an error', "PT workflow model isn't ActiveRecord::Base subclass so Rails isn't needed",
              good_options.update({models: ['not_rails_pivotal_tracker_feature']}).update({no_rails: true})


      # FIXME need to 'unload' Rails
      it_will 'raise error', "model is ActiveRecord::Base subclass so Rails is needed",
              AASM_StateChart::NoRailsConfig_Error,
              good_options.update({models: ['single_state']}).update({no_rails: true})

    end



  end
end

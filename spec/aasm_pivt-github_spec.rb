# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'

require 'fileutils'


#- - - - - - - - - -

describe AASM_StateChart::AASM_StateCharts do

  include GraphvizSpecHelper

  describe 'pivotalTracker and github model classes' do


    it_will 'not raise an error', 'github',
            good_options.update({models: ['git_hub']})
                .update({path: File.join(INCLUDE_PATH, 'shf')})
                .update({config_file: File.join(INCLUDE_PATH, 'shf', 'aasm_diagram_blue_green_config.yml')})
                .update({directory: File.join(INCLUDE_PATH, 'shf')})


# aasm_statecharts -i ./spec/fixtures/shf -d ./spec/spec-out/shf -c ./spec/fixtures/shf/aasm_diagram_blue_green_config.yml pivotal_tracker_feature

    it_will 'not raise an error', 'pivotal_tracker_feature',
            good_options.update({models: ['pivotal_tracker_feature']})
                .update({path: File.join(INCLUDE_PATH, 'shf')})
                .update({config_file: File.join(INCLUDE_PATH, 'shf', 'aasm_diagram_blue_green_config.yml')})
                .update({directory: File.join(INCLUDE_PATH, 'shf')})
                .update({no_rails: true})


  end


end

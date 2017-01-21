# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'
require 'statechart_helper'

require 'graphviz'

require 'fileutils'




def good_options

  include_path = File.join(__dir__, 'fixtures','shf')

  nice_config_fn = File.join(include_path, 'nice_config_opts.yml')

  options = {
      all: false,
      directory: OUT_DIR,
      format: 'png',
      models: ['pivotal_tracker_feature'],
      config_file: nice_config_fn,
      path: include_path
  }
end

#- - - - - - - - - -

describe AASM_StateChart::AASM_StateCharts do
  include SpecHelper


  Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


  describe 'pivotalTracker and github model classes' do
    options = good_options


    it_will 'not raise an error', 'load github',
            good_options.update({models: ['git_hub']})


    it_will 'not raise an error', 'load pivotal_tracker_feature',
            good_options.update({models: ['pivotal_tracker_feature']})


  end


end

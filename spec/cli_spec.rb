# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'
require 'statechart_helper'


describe AASM_StateChart::CLI do
  include SpecHelper


  Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


  options = {
      all: false,
      directory: OUT_DIR,
      format: 'png',
  }


  let(:cli) { AASM_StateChart::CLI.new(options).run}

  it 'warns when given a class that does not have aasm included' do

    options[:models] = ['no_aasm']

    expect { cli }.to raise_error(AASM_StateChart::NoAASM_Error)
  end

  it 'warns when given a class that has no states defined' do
    options[:models] = ['empty_aasm']
    expect { cli }.to raise_error(AASM_StateChart::NoStates_Error)
  end

  it 'fails if an invalid file format is given' do
    options[:format] = 'blorf'
    options[:models] = ['single_state']
    expect { cli }.to raise_error(AASM_StateChart::BadFormat_Error)
  end

  describe 'configuration' do

    it 'no config file exists' do

    end

    it 'config file option given is non-existent' do

    end

    it 'config file sets font and size for node ' do

    end
  end

end

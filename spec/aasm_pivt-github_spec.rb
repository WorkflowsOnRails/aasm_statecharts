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

DEFAULT_MODEL = 'pivotal_tracker_feature'



def rm_specout_outfile(outfile = "#{DEFAULT_MODEL}.png")
  fullpath = File.join(OUT_DIR, outfile)
  # FileUtils.rm fullpath if File.exist? fullpath
  # puts "     (cli_spec: removed #{fullpath})"
end


# alias shared example call for readability
RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_will, 'it will'
end

#- - - - - - - - - - 
RSpec.shared_examples 'use doc directory' do |desc, options|

  it "#{desc}" do
    doc_dir = File.absolute_path(File.join(__dir__, '..', 'doc'))

    FileUtils.rm_r(doc_dir) if Dir.exist? doc_dir

    expect { AASM_StateChart::AASM_StateCharts.new(options).run }.not_to raise_error
    expect(Dir).to exist(doc_dir)
    expect(File).to exist(File.join(doc_dir, "#{DEFAULT_MODEL}.png"))

    FileUtils.rm_r(doc_dir)
  end

end


RSpec.shared_examples 'have attributes = given config' do |item_name, item, options={}|

  item_attribs = item.each_attribute(true) { |a| a }

  options.each do |k, v|
    # GraphViz returns the keys as strings
    it "#{item_name} #{k.to_s}" do
      expect(item_attribs.fetch(k.to_s, nil)).not_to be_nil # will be something like a GraphViz::Types::EscString
      expect(item_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')
    end

  end

end


RSpec.shared_examples 'have graph attributes = given config' do |item, options={}|

  item_attribs = item.each_attribute { |a| a }

  options.each do |k, v|

    # GraphViz returns the keys as strings

    it "graph #{k.to_s}" do

      expect(item_attribs.fetch(k.to_s, nil)).not_to be_nil # will be something like a GraphViz::Types::EscString
      expect(item_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')

    end

  end

end


RSpec.shared_examples 'raise error' do |desc, error, options|
  it desc do
    expect { AASM_StateChart::AASM_StateCharts.new(options).run }.to raise_error(error)
  end
end


RSpec.shared_examples 'not raise an error' do |desc, options|
  options.inspect

  it desc do
    expect { AASM_StateChart::AASM_StateCharts.new(options).run }.not_to raise_error
  end
end


#- - - - - - - - - - 

def config_from(fn)
  config = {}
  if File.exist? fn
    File.open fn do |cf|
      begin
        config = Psych.safe_load(cf)
      rescue Psych::SyntaxError => ex
        ex.message
      end
    end
  end

  config
end



def good_options

  include_path = File.join(__dir__, 'fixtures','shf')

  nice_config_fn = File.join(include_path, 'nice_config_opts.yml')


  options = {
      all: false,
      directory: OUT_DIR,
      format: 'png',
      models: [DEFAULT_MODEL],
      config_file: nice_config_fn,
      path: include_path
  }
end

#- - - - - - - - - -

describe AASM_StateChart::AASM_StateCharts do
  include SpecHelper


  Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


  describe 'checks model classes' do
    options = good_options


    it_will 'not raise an error', 'load github',
            good_options.update({models: ['git_hub']})


    it_will 'not raise an error', 'load pivotal_tracker_feature',
            good_options.update({models: ['pivotal_tracker_feature']})


  end


end

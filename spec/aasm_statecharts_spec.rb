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

DEFAULT_MODEL = 'two_simple_states'


def good_options
  options = {
      all: false,
      directory: OUT_DIR,
      format: 'png',
      models: [DEFAULT_MODEL]
  }
end


def rm_specout_outfile(outfile = "#{DEFAULT_MODEL}.png")
  fullpath = File.join(OUT_DIR, outfile)
  FileUtils.rm fullpath if File.exist? fullpath
  puts "     (cli_spec: removed #{fullpath})"
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

#- - - - - - - - - - 

describe AASM_StateChart::AASM_StateCharts do
  include SpecHelper


  Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


  describe 'checks model classes' do
    options = good_options


    it 'error if both --all and a model is given' do
      pending # FIXME
    end

    it 'model model model (multiple models)' do
      pending # FIXME
    end

    it 'warns when given a class that does not have aasm included' do
      options[:models] = ['no_aasm']
      expect { AASM_StateChart::AASM_StateCharts.new(options).run }.to raise_error(AASM_StateChart::NoAASM_Error)
    end

    it 'warns when given a class that has no states defined' do
      options[:models] = ['empty_aasm']
      expect { AASM_StateChart::AASM_StateCharts.new(options).run }.to raise_error(AASM_StateChart::NoStates_Error)
    end

    it 'fails if an invalid file format is given' do
      options[:format] = 'blorf'
      options[:models] = ['single_state']
      expect { AASM_StateChart::AASM_StateCharts.new(options).run }.to raise_error(AASM_StateChart::BadFormat_Error)
    end

  end


  describe 'output directory' do

    after(:each) { rm_specout_outfile }

    it_will 'use doc directory', 'no directory option provided', good_options.reject! { |k, v| k == :directory }
    it_will 'use doc directory', 'directory = empty string', good_options.update({directory:  ''})


    it 'creates the directory if it does not exist' do

      test_dir = File.join(__dir__, 'blorf')
      FileUtils.rm_r(test_dir) if Dir.exist? test_dir

      options = good_options
      options[:directory] = test_dir

      AASM_StateChart::AASM_StateCharts.new(options).run

      expect(Dir).to exist(test_dir)
      FileUtils.rm_r(test_dir)
    end

  end


  describe 'configuration' do

    options = good_options

    describe 'problems' do

      after(:each) { rm_specout_outfile }

      it 'error: config file option given is non-existent ' do
        options[:config_file] = 'blorfy.blorf'
        expect { AASM_StateChart::AASM_StateCharts.new(options).run }.to raise_error(Errno::ENOENT)
      end

    end

    it 'no config file exists, use the default options' do
      expect { AASM_StateChart::AASM_StateCharts.new(good_options).run }.not_to raise_error
      rm_specout_outfile
    end


    describe 'config file sets font and size for node ' do

      ugly_config_fn = File.join(__dir__, 'fixtures', 'ugly_config_opts.yml')

      ugly_config = {}
      File.open ugly_config_fn do |cf|
        begin
          ugly_config = Psych.safe_load(cf)
        rescue Psych::SyntaxError => ex
          ex.message
        end
      end

      options[:config_file] = ugly_config_fn
      options[:format] = 'dot'

      AASM_StateChart::AASM_StateCharts.new(options).run

      dot_output = "#{OUT_DIR}/#{options[:models].first}.#{options[:format]}"

      graph_out = GraphViz.parse(dot_output)

      # GraphViz does not have global attributes, so you have to check individual nodes or edges
      node0 = graph_out.get_node_at_index(0)
      edge0 = graph_out.get_edge_at_index(0)

      it_will 'have graph attributes = given config', graph_out, ugly_config['graph']['graph_style']
      it_will 'have attributes = given config', 'node', node0, ugly_config['graph']['node_style']
      it_will 'have attributes = given config', 'edge', edge0, ugly_config['graph']['edge_style']

      rm_specout_outfile "#{options[:models].first}.#{options[:format]}"
    end

  end

  describe 'rails class' do

    it 'error if it is not run under Rails config directory' do
      options = good_options
      # FIXME how to run this under a different dir so it can fail?
      expect{AASM_StateChart::AASM_StateCharts.new(options).run}.to raise_error AASM_StateChart::NoRailsConfig_Error
    end

    it 'loads a rails class Purchase' do
      ugly_config_fn = File.join(__dir__, 'fixtures', 'ugly_config_opts.yml')

      options = {format: 'png', models: ['purchase'], directory: OUT_DIR}
      options[:config_file] = ugly_config_fn

      AASM_StateChart::AASM_StateCharts.new(options).run

      expect(File.exist?(File.join(OUT_DIR, 'purchase.png')))
      rm_specout_outfile('purchase.png')
    end

  end
end

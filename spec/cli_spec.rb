# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'
require 'statechart_helper'

require 'fileutils'


def good_options
  options = {
      all: false,
      directory: OUT_DIR,
      format: 'png',
      models: ['single_state']
  }
end


# alias shared example call for readability
RSpec.configure do |c|
  c.alias_it_should_behave_like_to :it_will, 'it will'
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


RSpec.shared_examples 'have graph attributes = given config' do | item, options={}|

  item_attribs = item.each_attribute { |a| a }

  options.each do |k, v|
    # GraphViz returns the keys as strings
    it "graph #{k.to_s}" do
      expect(item_attribs.fetch(k.to_s, nil)).not_to be_nil # will be something like a GraphViz::Types::EscString
      expect(item_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')
    end

  end

end



describe AASM_StateChart::CLI do
  include SpecHelper


  Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


  let(:cli) { |opt| AASM_StateChart::CLI.new(opts).run }

  describe 'checks model classes' do
    options = good_options

    it 'warns when given a class that does not have aasm included' do

      options[:models] = ['no_aasm']

      expect { AASM_StateChart::CLI.new(options).run }.to raise_error(AASM_StateChart::NoAASM_Error)
    end

    it 'warns when given a class that has no states defined' do
      options[:models] = ['empty_aasm']
      expect { AASM_StateChart::CLI.new(options).run }.to raise_error(AASM_StateChart::NoStates_Error)
    end

    it 'fails if an invalid file format is given' do
      options[:format] = 'blorf'
      options[:models] = ['single_state']
      expect { AASM_StateChart::CLI.new(options).run }.to raise_error(AASM_StateChart::BadFormat_Error)
    end

  end

  describe 'output directory' do

    options = good_options

    it 'uses current directory if none specified' do
      options.reject! { |k, v| k == :directory }
      expect { AASM_StateChart::CLI.new(options).run }.not_to raise_error
    end

    it 'uses current directory if empty string is given' do
      options[:directory] = ''
      expect { AASM_StateChart::CLI.new(options).run }.not_to raise_error
    end

    it 'creates the directory if it does not exist' do
      # ensure there's no directory name blorf
      test_dir = File.join(__dir__, 'blorf')
      FileUtils.rm_r(test_dir) if Dir.exist? test_dir

      options[:directory] = test_dir

      AASM_StateChart::CLI.new(options).run

      expect(File).to exist(test_dir)

      FileUtils.rm_r(test_dir)
    end


  end


  describe 'configuration' do

    options = good_options

    describe 'problems' do

      it 'config file option given is non-existent ' do
        options[:config_file] = 'blorfy.blorf'
        expect { AASM_StateChart::CLI.new(options).run }.to raise_error(Errno::ENOENT)
      end

    end

    it 'no config file exists, use the default options' do
      # get the default options

      # the options used after initializing = the default options

    end


    require 'graphviz'

    describe 'config file sets font and size for node ' do

      good_config_fn = File.join(__dir__, 'fixtures', 'good_config_opts.yml')

      good_config = {}
      File.open good_config_fn do |cf|
        begin
          good_config = Psych.safe_load(cf)
        rescue Psych::SyntaxError => ex
          ex.message
        end
      end

      options[:config_file] = good_config_fn
      options[:format] = 'dot'

      AASM_StateChart::CLI.new(options).run

      dot_output = "#{OUT_DIR}/#{options[:models].first}.#{options[:format]}"

      graph_out = GraphViz.parse(dot_output)

      # GraphViz does not have global attributes, so you have to check individual nodes or edges
      node0 = graph_out.get_node_at_index(0)
      edge0 = graph_out.get_edge_at_index(0)


      it_will 'have graph attributes = given config', graph_out, good_config['graph']['graph_style'] # FIXME how to get the graph attribs
      it_will 'have attributes = given config', 'node', node0, good_config['graph']['node_style']
      it_will 'have attributes = given config', 'edge', edge0, good_config['graph']['edge_style']

      options[:format] = 'jpg'
      AASM_StateChart::CLI.new(options).run

    end

  end

end

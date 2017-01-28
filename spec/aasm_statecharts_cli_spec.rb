#--------------------------
#
# @file aasm_statecharts_cli_spec.rb
#
# @desc Description
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   1/21/17
#
#
#--------------------------


require 'spec_helper'

load File.expand_path(File.join(__dir__, '..', 'bin', 'aasm_statecharts'))


RSpec.shared_examples 'handle args' do |args, result|

  it "#{args} with result output #{result}" do
    expect { AASM_StateChart::AASM_Statecharts_CLI.new(args) }.to output(result).to_stdout
  end

end


RSpec.shared_examples 'raise error with args' do |args, error|

  it "#{args} raises error #{error}" do
    expect { AASM_StateChart::AASM_Statecharts_CLI.new(args) }.to raise_error error
  end

end

RSpec.shared_examples 'test the arg with options:' do |arg_info, result|

  it_will 'raise error with args', ["-#{arg_info[:short]}", "#{arg_info[:option]}"], AASM_StateChart::AASM_NoModels
  it_will 'raise error with args', ["--#{arg_info[:long]}", "#{arg_info[:option]}"], AASM_StateChart::AASM_NoModels

  it_will 'raise error with args', ["--#{arg_info[:long]}"], OptionParser::MissingArgument

  it_will 'handle args', ["-#{arg_info[:short]}", "#{arg_info[:option]}", "#{arg_info[:model]}"], result

end


RSpec.shared_examples 'test graph-attrib option:' do |arg_info, result, result_with_model|

  it_will 'handle args', ["-#{arg_info[:short]}", "#{arg_info[:option]}"], result
  it_will 'handle args', ["--#{arg_info[:long]}", "#{arg_info[:option]}"], result

  it_will 'handle args', ["-#{arg_info[:short]}", "#{arg_info[:option]}", "#{arg_info[:model]}"], result_with_model # should output AND generate the model

end

#- - - - - - - - - - - - - - - - - - - - - - - -

describe AASM_StateChart::AASM_Statecharts_CLI do

  describe '#version_or_graph_configs_opt?(args, opts)' do

    let(:cli) { AASM_StateChart::AASM_Statecharts_CLI.new(['-a']) }

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {})).to be_falsey
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {version: false, dump_configs: false})).to be_falsey
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {version: false, dump_configs: :all})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {version: true, dump_configs: false})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {version: true, dump_configs: :all})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {version: true})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {version: false})).to be_falsey
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {dump_configs: :all})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {dump_configs: :graph})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {dump_configs: :nodes})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {dump_configs: :edges})).to be_truthy
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {dump_configs: :blorf})).to be_falsey
    end

    it 'version: false, dump_configs: false == false' do
      expect(cli.version_or_graph_configs_opt?('', {dump_configs: false})).to be_falsey
    end

  end


  describe 'combinations of options' do

    it 'pending: valid and invalid combinations of options' do
      pending
    end

  end


  describe 'command line options' do

    # shared: is valid = no error message, continue
    # bad option = error message and parse info.  no program execution

    describe 'bad args/opts' do
      it_will 'raise error with args', [''], AASM_StateChart::AASM_NoModels

      it_will 'raise error with args', ['-blor'], OptionParser::InvalidOption

    end

    describe 'version' do
      it_will 'handle args', ['-v'], "#{AASM_StateChart::VERSION}\n"
      it_will 'handle args', ['--version'], "#{AASM_StateChart::VERSION}\n"

      it_will 'raise error with args', ['--version blorf'], OptionParser::InvalidOption

    end

    describe 'include path' do

      args = {short: 'i', long: 'include', option: './spec/fixtures', model: 'single_state'}

      it_will 'test the arg with options:', args, /([\s\S]*)\* diagrammed single_state and saved to \.\/doc\/single_state.png/

    end

    describe 'graph-configs' do

      describe 'bad option' do
        args = {short: 'g', long: 'graph-configs', option: 'blorf', model: 'single_state'}

        it_will 'raise error with args', ["-#{args[:short]}", "#{args[:option]}"], AASM_StateChart::CLI_Inputs_ERROR
        it_will 'raise error with args', ["--#{args[:long]}", "#{args[:option]}"], AASM_StateChart::CLI_Inputs_ERROR

        it_will 'raise error with args', ["-#{args[:short]}", "#{args[:option]}", "#{args[:model]}"], AASM_StateChart::CLI_Inputs_ERROR #/\* diagrammed single_state and saved to \.\/doc\/single_state.png/

      end

      describe 'graphs' do
        args = {short: 'g', long: 'graph-configs', option: 'graph', model: 'single_state'}

        it_will 'test graph-attrib option:', args, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::GRAPH_ATTRIBS_TITLE})/, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::GRAPH_ATTRIBS_TITLE})([\s\S]*)single_state.png/

      end

      describe 'nodes' do
        args = {short: 'g', long: 'graph-configs', option: 'nodes', model: 'single_state'}
        it_will 'test graph-attrib option:', args, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::NODE_ATTRIBS_TITLE})/, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::NODE_ATTRIBS_TITLE})([\s\S]*)single_state.png/
      end

      describe 'edges' do
        args = {short: 'g', long: 'graph-configs', option: 'edges', model: 'single_state'}
        it_will 'test graph-attrib option:', args, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::EDGE_ATTRIBS_TITLE})/, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::EDGE_ATTRIBS_TITLE})([\s\S]*)single_state.png/

      end

      describe 'colors' do
        args = {short: 'g', long: 'graph-configs', option: 'colors', model: 'single_state'}
        it_will 'test graph-attrib option:', args, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::COLORS_ATTRIBS_TITLE})/, /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::COLORS_ATTRIBS_TITLE})([\s\S]*)single_state.png/

      end

      describe 'all' do
        args = {short: 'g', long: 'graph-configs', option: 'blorf', model: 'single_state'}

        it_will 'handle args', ["-#{args[:short]}"], /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::ALL_ATTRIBS_TITLE})/
        it_will 'handle args', ["--#{args[:long]}"], /Title([\s\S]*)(#{AASM_StateChart::AASM_StateCharts::ALL_ATTRIBS_TITLE})/

        it_will 'raise error with args', ["-#{args[:short]}", "#{args[:option]}"], AASM_StateChart::CLI_Inputs_ERROR
        it_will 'raise error with args', ["-#{args[:long]}", "#{args[:option]}"], AASM_StateChart::CLI_Inputs_ERROR

        it_will 'raise error with args', ["-#{args[:short]}", "#{args[:option]}", "#{args[:model]}"], AASM_StateChart::CLI_Inputs_ERROR
        it_will 'raise error with args', ["--#{args[:long]}", "#{args[:option]}", "#{args[:model]}"], AASM_StateChart::CLI_Inputs_ERROR


      end


    end

    describe 'root' do
      args = {short: 'r', long: 'root', option: 'ActiveRecord', model: 'single_state'}

      it_will 'test the arg with options:', args, /([\s\S]*)\* diagrammed single_state and saved to \.\/doc\/single_state.png/

    end

    describe 'subclass-root' do
      args = {short: 's', long: 'subclass-root', option: 'ActiveRecord', model: 'single_state'}

      it_will 'test the arg with options:', args, /([\s\S]*)\* diagrammed single_state and saved to \.\/doc\/single_state.png/

    end

    describe 'directory' do

      args = {short: 'd', long: 'directory', option: './docs/', model: 'single_state'}

      it_will 'test the arg with options:', args, /([\s\S]*)\* diagrammed single_state and saved to \.\/docs\/single_state.png/

    end


    describe 'config file' do

      args = {short: 'c', long: 'config', option: './spec/fixtures/ugly_config_opts.yml', model: 'single_state'}

      it_will 'test the arg with options:', args, /([\s\S]*)\* diagrammed single_state and saved to \.\/doc\/single_state.png/

    end

    describe 'file format' do

      args = {short: 'f', long: 'file-type', option: 'jpg', model: 'single_state'}

      it_will 'test the arg with options:', args, /([\s\S]*)\* diagrammed single_state and saved to \.\/doc\/single_state.jpg/

    end


    describe 'arg = model name' do

      it_will 'handle args', ['single_state'], /([\s\S]*)\* diagrammed single_state and saved to \.\/doc\/single_state.png/

    end

    describe 'model filename has a path on it' do

      this_path = File.absolute_path( File.join(__dir__, '..') )

      describe "#{this_path}/app/models/purchase.rb" do

        it_will 'handle args', ["#{File.join(this_path,'/app/models/purchase')}"],
                /([\s\S]*)\* diagrammed purchase and saved to \.\/doc\/purchase.png/
      end

      describe "./app/models/git_hub  (no extension)" do

        it_will 'handle args', ["./app/models/git_hub"],
                /([\s\S]*)\* diagrammed git_hub and saved to \.\/doc\/git_hub.png/
      end


      describe "#{this_path}/app/models/git_hub  (no extension)" do

        it_will 'handle args', ["#{File.join(this_path,'/app/models/git_hub')}"],
                /([\s\S]*)\* diagrammed git_hub and saved to \.\/doc\/git_hub.png/
      end


      describe "-i #{this_path}  app/models/claim.rb" do

        it_will 'handle args', ["-i", "#{this_path}", "app/models/claim"],
                /([\s\S]*)\* diagrammed claim and saved to \.\/doc\/claim.png/
      end

      describe 'error: file not found' do

        it_will 'raise error with args', ["#{File.join(this_path, '/app/models/not-a-file')}"],
                LoadError
      end


    end


    describe 'all' do
      it_will 'handle args', ['-a'], "#{AASM_StateChart::VERSION}\n"
      it_will 'handle args', ['--all'], "#{AASM_StateChart::VERSION}\n"

      it_will 'raise error with args', ['--all blorf'], OptionParser::InvalidOption

    end


  end


end
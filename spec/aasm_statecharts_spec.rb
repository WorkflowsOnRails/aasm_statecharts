# Unit tests for aasm_statecharts. All checks are performed against
# the representation held by Ruby-Graphviz, not the files written
# to disk; we're dependent on Ruby-Graphviz and dot getting it right.
#
# @author Brendan MacDonell, Ashley Engelund
#

require 'spec_helper'

require 'fileutils'

UGLY_CONFIG_FN = File.join(__dir__, 'fixtures', 'ugly_config_opts.yml')


#- - - - - - - - - -

describe AASM_StateChart::AASM_StateCharts do


  describe 'include path' do

    it_will 'raise error', 'blank path',
            AASM_StateChart::BadPath_Error,
            good_options.update({path: ''})

    it_will 'raise error', 'nil path',
            AASM_StateChart::BadPath_Error,
            good_options.update({path: nil})

    it_will 'raise error', 'ill-formed path',
            AASM_StateChart::PathNotLoaded_Error,
            good_options.update({path: 'blorfy, blorf, blorf? blorf! @blorf'})

    it_will 'raise error', 'path dir does not exist',
            AASM_StateChart::PathNotLoaded_Error,
            good_options.update({path: 'does/not/exist'})


    it 'handles a list of paths' do

      rails_models_path = File.join(__dir__, '..', 'app', 'models')

      # have a model in each of the included paths
      options = good_options.update({path: "#{INCLUDE_PATH}#{File::PATH_SEPARATOR}#{rails_models_path}"}).update({models: ['purchase', 'single_state']})

      # will produce 2 files

      AASM_StateChart::AASM_StateCharts.new(options).run

      expect(File.exist?(File.join(OUT_DIR, 'single_state.png')))
      expect(File.exist?(File.join(OUT_DIR, 'purchase.png')))

      rm_specout_outfile('single_state.png')
      rm_specout_outfile('purchase.png')

    end

  end


  describe 'print out attributes for config files' do
    options = good_options

    it 'graph attributes and options' do
      options = good_options.merge({dump_configs: :graph}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run
    end

    it 'node attributes and options' do
      options = good_options.merge({dump_configs: :nodes}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run

    end

    it 'edge attributes and options' do
      options = good_options.merge({dump_configs: :edges}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run
    end

    it 'color attributes' do
      options = good_options.merge({dump_configs: :colors}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run
    end

    it':formats' do
      options = good_options.merge({dump_configs: :formats}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run
    end

    it':graphtype,' do
      options = good_options.merge({dump_configs: :programs}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run
    end

    it':graphtype,' do
      options = good_options.merge({dump_configs: :graphtype}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run
    end

    it 'all attributes' do
      options = good_options.merge({dump_configs: :all}).update({models: []})
      AASM_StateChart::AASM_StateCharts.new(options).run
    end



  end


  describe 'root and subclass-root' do
    options = good_options


    it 'give a root class' do
      pending
      good_options.merge({root_class: ['single_state']})
    end


    it "give a subclass-root class" do
      pending
      good_options.merge({subclass_root_model: ['single_state']})
    end

    it_will 'raise error', 'cannot have same model for root and subclass-root',
            AASM_StateChart::RootAndSubclassSame_Error,
            good_options.merge({root_class: ['single_state']}).merge({subclass_root_model: ['single_state']})


  end


  describe 'output directory' do

    after(:each) { rm_specout_outfile }

    it_will 'use doc directory', 'no directory option provided', good_options.reject! { |k, v| k == :directory }
    it_will 'use doc directory', 'directory = empty string', good_options.update({directory: ''})


    it 'creates the directory if it does not exist' do

      test_dir = File.join(__dir__, 'blorf')
      FileUtils.rm_r(test_dir) if Dir.exist? test_dir

      options = good_options
      options[:directory] = test_dir

      AASM_StateChart::AASM_StateCharts.new(options).run

      expect(Dir).to exist(test_dir)
      FileUtils.rm_r(test_dir)
    end


    it 'handles a path that exists' do
      pending
    end


    it "handles a path that doesn't exist at all" do
      pending
    end


    it "handles a path that only first 2 dirs exist" do
      pending
    end

  end


  describe 'configuration file' do
    after(:each) { rm_specout_outfile }

    options = good_options

    it_will 'raise error', 'error: config file option given is non-existent',
            AASM_StateChart::NoConfigFile_Error,
            good_options.update({config_file: 'blorfy.blorf'})

    it_will 'not raise an error', 'no config file exists, use the default options',
            good_options


    describe 'config file graph, node, edge styles ' do

      # TODO simplify! refactor!  shared_context ?

      options[:config_file] = UGLY_CONFIG_FN
      options[:format] = 'dot'
      options[:path] = INCLUDE_PATH

      let!(:graph_out) {
        AASM_StateChart::AASM_StateCharts.new(options).run

        dot_output = "#{OUT_DIR}/#{options[:models].first}.#{options[:format]}"

        GraphViz.parse(dot_output)
      }

      # GraphViz does not have global attributes, so you have to check individual nodes or edges
      #   node 0 is the title

      let!(:node1) { graph_out.get_node_at_index(1) }
      let(:node_attribs) { node1.each_attribute { |a| a } }

      let!(:edge0) { graph_out.get_edge_at_index(0) }
      let(:edge_attribs) { edge0.each_attribute { |a| a } }

      let(:graph_attribs) { graph_out.each_attribute { |a| a } }


      ugly_config = config_from UGLY_CONFIG_FN


      (ugly_config['graph']['node_style']).each do |k, v|

        it "node #{k.to_s}" do

          node_a = node_attribs
          node_val = node_attribs.fetch(k.to_s, nil)

          expect(node_attribs.fetch(k.to_s, nil)).not_to be_nil    # will be something like a GraphViz::Types::EscString
          expect(node_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')

        end

      end

      (ugly_config['graph']['edge_style']).each do |k, v|

        it "edge #{k.to_s}" do

          expect(edge_attribs.fetch(k.to_s, nil)).not_to be_nil # will be something like a GraphViz::Types::EscString
          expect(edge_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')

        end

      end

      (ugly_config['graph']['graph_style']).each do |k, v|

        it "graph #{k.to_s}" do

          expect(graph_attribs.fetch(k.to_s, nil)).not_to be_nil # will be something like a GraphViz::Types::EscString
          expect(graph_attribs.fetch(k.to_s, '').to_s).to eq("\"#{v}\"") #('"Courier New"')

        end

      end

      #   it_will 'have graph attributes = given config', graph_out, ugly_config['graph']['graph_style']
      #   it_will 'have attributes = given config', 'node', node0, ugly_config['graph']['node_style']
      #   it_will 'have attributes = given config', 'edge', edge0, ugly_config['graph']['edge_style']


      rm_specout_outfile "#{options[:models].first}.#{options[:format]}"
    end

  end

  describe 'checks model classes' do


    it_will 'raise error', "model cannot be loaded (blorfy doesn't exist)",
            AASM_StateChart::ModelNotLoaded_Error,
            good_options.update({models: ['blorfy']})

    it_will 'raise error', 'warns when class does not have aasm included',
            AASM_StateChart::NoAASM_Error,
            good_options.update({models: ['no_aasm']})

    it_will 'raise error', 'warns when class has no states defined',
            AASM_StateChart::NoStates_Error,
            good_options.update({models: ['empty_aasm']})


    it_will 'raise error', 'fails if an invalid file format is given',
            AASM_StateChart::BadFormat_Error,
            good_options.update({models: ['single_state'], format: 'blorf'})


    it_will 'not raise an error', 'load a list of valid classes',
            good_options.update({models: ['single_state', 'many_states']})

    it_will 'raise error', 'one bad class in a list',
            AASM_StateChart::ModelNotLoaded_Error,
            good_options.update({models: ['single_state', 'blorf']})

    it_will 'not raise an error', "model isn't ActiveRecord::Base subclass",
            good_options.update({models: ['no_rails_two_simple_states']})


  end


  describe 'rails class' do

    describe 'no rails = true' do

      it_will 'not raise an error', "model isn't ActiveRecord::Base subclass so Rails isn't needed",
              good_options.update({models: ['no_rails_two_simple_states']}).update({no_rails: true})



      it_will 'raise error', "model is ActiveRecord::Base subclass so Rails is needed",
              AASM_StateChart::NoRailsConfig_Error,
              good_options.update({models: ['single_state']}).update({no_rails: true})

    end


    it 'no error if it is not run under Rails config directory' do

      options = good_options

      orig_dir = FileUtils.getwd
      FileUtils.cd (File.expand_path(File.join(__dir__, 'fixtures')))

      expect { AASM_StateChart::AASM_StateCharts.new(options).run }.to raise_error AASM_StateChart::ModelNotLoaded_Error

      FileUtils.cd orig_dir

    end


    it 'loads a rails class: Purchase' do

      options = {format: 'png', models: ['purchase'], directory: OUT_DIR}
      options[:config_file] = UGLY_CONFIG_FN
      options[:path] = File.expand_path(File.join(__dir__, '..', 'app', 'models'))

      AASM_StateChart::AASM_StateCharts.new(options).run

      expect(File.exist?(File.join(OUT_DIR, 'purchase.png')))
      rm_specout_outfile('purchase.png')
    end

  end
end

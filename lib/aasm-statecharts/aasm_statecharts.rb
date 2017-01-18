require 'graphviz'
require_relative 'transition_table'

require_relative 'chart_renderer'

# Library module than handles translating AASM state machines to statechart
# diagrams.
#
# Usage is simple. First, create an instance of AASM_StateChart::Renderer, passing
# in the class that has the AASM state machine that you would like to generate
# the diagram of. Then call #save with the filename to save the diagram to, as well
# as the format to save in. This must be one of the formats specified in
# GraphViz::Constants::FORMATS.
#
# For example, to render the state machine associated with a class named ModelClass,
# you would do the following:
#   
#   renderer = AASM_StateChart::Renderer.new(ModelClass)
#   renderer.save(filename, format: 'png')
#
# @author Brendan MacDonell and Ashley Engelund
#
# @see http://www.graphviz.org/Documentation.php for style and attribute documentation
#------------------------------------------------------------


module AASM_StateChart

  class AASM_StateChart_Error < StandardError
  end

  class NoAASM_Error < AASM_StateChart_Error
  end

  class NoStates_Error < AASM_StateChart_Error
  end


  class CLI


    def initialize(options)

      @output_dir = Dir.mkdir(options[:directory]) unless Dir.exists? options[:directory]

      @models = load_models options[:all], options[:models]

      @show_transition_table = options[:transition_table]


    end


    def run

      @models.each do |klass|

        name = klass.name.underscore

        renderer = AASM_StateChart::Renderer.new(klass, @show_transition_table)

        filename = "#{@output_dir}/#{name}.#{options[:format]}"

        renderer.save(filename, format: options[:format])

        puts " * rendered #{name} to #{filename}"
      end

    end


    # - - - - - - - -
    private

    #  used to get all subclasses of ActiveRecord.  Is there a way to get them without loading all of rails?
    def load_rails!
      unless File.exists? './config/environment.rb'
        script_name = File.basename $PROGRAM_NAME
        puts 'error: unable to find ./config/environment.rb.'
        puts "Please run #{script_name} from the root of your Rails application."
        exit(1)
      end

      require './config/environment'
    end


    def load_models(load_all, models_named)

      @models = load_all ? collect_all_models : load_models_named(models_named)

    end


    def load_models_named(model_names)
      model_names.map { |model_name| model_name.classify.constantize }
    end


    def collect_all_models
      Rails::Application.subclasses.first.eager_load!
      ActiveRecord::Base.descendants.select { |klass| klass.respond_to? :aasm }
    end

  end

end

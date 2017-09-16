require 'graphviz'
require 'psych'

require 'aasm'

# TODO these shouldn't be necessary,... right?
require_relative 'transition_table'
require_relative 'chart_renderer'
require_relative 'errors'
require_relative 'graphviz_options'

require 'pp'

require 'active_support'
require 'active_support/core_ext' # must explicitly require so that blank? methods can be required/loaded


# Library module than handles translating AASM state machines to statechart
# diagrams.
#
# Usage is simple. First, create an instance of AASM_StateChart::Renderer, passing
# in the class that h                      s the AASM state machine that you would like to generate
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

  # TODO title and subtitle: use HtmlString? or plainshape

  # better error message if file not found

  class AASM_StateCharts


    def initialize(options={})

      @options = options
      #puts "\n\n@options: #{@options.inspect}"

      @include_paths = []
      @include_paths = get_included_paths options[:path] if options.has_key?(:path) # don't use fetch because nil is meaningful (we need to raise an error)


      if options[:models].empty? && !options[:dump_configs] && !options[:all]
        #if !options[:all] && options[:models].empty?  # should never happen; opts parsing should catch it
        raise AASM_NoModels, AASM_NoModels.error_message("You must specify a model to diagram or else use the --all option.")
      end

      @output_dir = get_output_dir options.fetch(:directory, '')

      load_rails unless @options[:no_rails]

      @models = get_models options[:all], options[:models]

      @show_transition_table = options[:transition_table]

      @format = verify_file_format options[:format]

      @config_options = Hash.new.merge(load_config_file(options.fetch(:config_file, '')))

    end


    def run

      if @options.fetch(:dump_configs, false)
        output = GraphvizOptions.dump_attribs @options[:dump_configs]
        puts output
      end

      unless @models.blank?
        @models.each do |m|

          begin
            klass = Module.const_get m


            name = klass.name.underscore

            if !(klass.respond_to? :aasm)
              raise NoAASM_Error, "ERROR: #{klass.name} does not include AASM.  No diagram generated."

            else

              if klass.aasm.states.empty?
                raise NoStates_Error, "ERROR: No states found for #{klass.name}!  No diagram generated"
              else

                renderer = AASM_StateChart::Chart_Renderer.new(klass, @show_transition_table, @config_options)

                filename = File.join(@output_dir, "#{name}.#{@format}")

                renderer.save(filename, format: @format)

                puts " * diagrammed #{name} and saved to #{filename}"

              end

            end


          rescue => e
            raise e #AASM_NotFound_Error, "\nERROR: Could not find the model in #{m}.\n"
          end
        end

      end

    end


    # - - - - - - - -
    private


    def get_included_paths(options_path)

      full_paths = []
      if options_path.blank?
        raise BadPath_Error, BadPath_Error.error_message("Could not read #{options_path}.  Please check it carefully. Use '#{File::PATH_SEPARATOR}' to separate directories.")

      elsif (paths = options_path.split File::PATH_SEPARATOR).count == 0
        raise BadPath_Error, BadPath_Error.error_message("Could not read #{options_path}.  Please check it carefully. Use '#{File::PATH_SEPARATOR}' to separate directories.")
      end

      paths.each do |path|
        fullpath = File.expand_path(path)

        if Dir.exist? fullpath
          $LOAD_PATH.unshift(fullpath) # add to the start of $LOAD_PATH
          full_paths << fullpath
        else
          raise PathNotLoaded_Error, PathNotLoaded_Error.error_message("Could not load path #{path}.")
        end

      end

      full_paths

    end


    def get_output_dir(options_dir)

      default_dir = 'doc' #'./doc'

      out_dir = options_dir == '' ? default_dir : options_dir

      # FIXME  if out_dir is a path, need to recurse down into it. then curse it again

      Dir.mkdir(out_dir) unless Dir.exist? out_dir
      out_dir
    end


    #  used to get all subclasses of ActiveRecord.  Is there a way to get them without loading all of rails?
    def load_rails

      unless File.exist? './config/environment.rb'
        script_name = File.basename $PROGRAM_NAME
        raise NoRailsConfig_Error, NoRailsConfig_Error.error_message("Unable to find ./config/environment.rb.\n Please run #{script_name} from the root of your Rails application.")
      end

      require './config/environment'
    end


    def get_models(all_option, models)

      model_classes = []

      if all_option
        puts "\n\nTBD: all_option\n\n"
      else

        models.each do |model|

          begin
            found_model = false

            fname = "#{model}.rb"

            found_model = require_or_load(model, fname)


            unless found_model

              i = 0

              while !found_model && i < @include_paths.size
                found_model = require_or_load(model, File.join(@include_paths[i], fname))
                i += 1
              end


            end

          rescue => e
            raise e
          end

          if found_model

            model_basename = File.basename model

            model_classes << File.basename(model_basename, File.extname(model_basename)).camelize

          else
            raise ModelNotLoaded_Error, ModelNotLoaded_Error.error_message("Could not load #{model} \n   Looked in #{@include_paths} and\n $LOAD_PATH: #{$LOAD_PATH.inspect}).")
          end

        end

      end # else not all_models

      model_classes

    end


    def require_or_load(model, fname)

      found_model = false

      if File.exist? fname

        try_methods = [:require, :require_relative]

        i = 0

        while !found_model && i < try_methods.size do

          begin
            found_model = try_requires(try_methods[i], model)
          rescue => e
            found_model = false
            raise e
          ensure
            i += 1
          end

        end

        unless found_model
          begin
            load fname
            found_model = true
          rescue
            found_model = false
          end
        end

      end

      found_model
    end


    def try_requires(method, model)
      success = false
      begin
        Kernel.send method, model
        success = true
      rescue => e
        success = false
        raise ModelNotLoaded_Error, ModelNotLoaded_Error.error_message("#{model} exists but there was an error when attempting: #{method.to_s} '#{model.to_s}':\n#{ModelNotLoaded_Error.show_cause(e)}\n\n")
      end
      success
    end


    def verify_file_format (format_extension)
      valid_formats = GraphViz::Constants::FORMATS
      unless valid_formats.include? format_extension
        valid_list = valid_formats.join ', '
        raise BadFormat_Error, BadFormat_Error.error_message("File format #{format_extension} is not a valid format.\n   These are the valid formats:\n  #{valid_list}")
      end

      format_extension
    end


    def load_config_file (config_fn)
      parsed_config = {}

      unless config_fn == ''
        if File.exist? config_fn
          File.open config_fn do |cf|
            begin
              parsed_config = Psych.safe_load(cf)
            rescue Psych::SyntaxError => ex
              ex.message
            end
          end
        else
          raise NoConfigFile_Error, NoConfigFile_Error.error_message("The config file #{config_fn} doesn't exist.")
        end

      end

      # need to flatten these 1 level to get them into what GraphViz expect
      parsed_opts = {}
      parsed_config.each do |k, v|
        parsed_config[k].each do |k2, v2|
          parsed_opts[k2] = v2
        end
      end
      symbolize_the_keys parsed_opts
    end


    # GraphViz expects keys to be symbols, but it's only safe (and user friendly) to have
    # keys as strings in a config file
    def symbolize_the_keys(hash)

      hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v.is_a?(Hash) ? symbolize_the_keys(v) : v }
    end


    # - - - - - -
    # old cruft
    def load_models(load_all, models_named)

      @models = load_all ? collect_all_models : load_models_named(models_named)

    end


    # old cruft
    def load_models_named(model_names)
      model_names.map do |model_name|

        # must strip off any leading path, add that path to the $Loadpath, and then set the model to just the filename
        just_model = File.basename model_name

        just_model.camelize.constantize
      end
    end


    # old cruft
    def collect_all_models

      Rails::Application.subclasses.first.eager_load!
      ActiveRecord::Base.descendants.select { |klass| klass.respond_to? :aasm }

    end


  end #class

end # module

require 'graphviz'
require_relative 'transition_table'

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


  class Renderer

    @CONF = {}

    ENTER_CALLBACKS = [:before_enter, :enter, :after_enter, :after_commit]
    EXIT_CALLBACKS = [:before_exit, :exit, :after_exit]

    TRANSITION_CALLBACKS = [:before, :on_transition, :after]

    TRANSITION_GUARDS = [:guards, :guard, :if]


    def initialize(klass, transition_table=false)

      init_config

      @start_node = nil
      @end_node = nil

      @graph = GraphViz.new(:statechart)
      @graph.type = 'digraph' # TODO config


      @transition_table = TransitionTable.new if transition_table

      # ruby-graphviz is missing an API to set styles in bulk, so set them here
      # TODO config
      @default_config[:graph_style].each { |k, v| @graph.graph[k] = v }
      @default_config[:node_style].each { |k, v| @graph.node[k] = v }
      @default_config[:edge_style].each { |k, v| @graph.edge[k] = v }


      if !(klass.respond_to? :aasm)
        raise NoAASM_Error, "ERROR: #{klass.name} does not include AASM.  No diagram generated."
      else
        if klass.aasm.states.empty?
          raise NoStates_Error, "ERROR: No states found for #{klass.name}!  No diagram generated"
        else
          klass.aasm.states.each { |state| render_state(state) }
          klass.aasm.events.each { |event| render_event(event) unless event.blank? }

          if transition_table
            klass.aasm.events.each do |event|
              unless event.blank?
                event.transitions.each { |t| @transition_table.add_transition(t, conditionals: transition_guards(t)) }
              end
            end
            transition_node_opts = @default_config[:transition_table_node_style].merge({label: @transition_table.render})
            @graph.add_nodes('State Transition Table', transition_node_opts) # TODO i18n table title or at least config
            # TODO  use add_graph instead?
          end
        end
      end

    end


    def save(filename, format: 'png')  # TODO config default output format
      @graph.output({format => filename})
    end


    def graph
      @graph
    end


    def transition_table
      @transition_table
    end


    def start_node
      if @start_node.nil?
        @start_node = @graph.add_nodes(SecureRandom.uuid, **@default_config[:start_node_style])
      end

      @start_node
    end


    def end_node
      if @end_node.nil?
        @end_node = @graph.add_nodes(SecureRandom.uuid, **@default_config[:end_node_style])
      end

      @end_node
    end


    #======
    private

    def get_options(options, keys)
      options
          .select { |key| keys.include? key }
          .values
          .flatten
    end


    def get_callbacks(options, keys)
      get_options(options, keys)
          .map { |callback| "#{callback}();" }
          .join(' ')
    end


    def transition_guards(transition)
      get_options(transition.options, TRANSITION_GUARDS)
    end


    def render_state(state)
      enter_callbacks = get_callbacks(state.options, ENTER_CALLBACKS)
      exit_callbacks = get_callbacks(state.options, EXIT_CALLBACKS)

      callbacks_list = []
      callbacks_list << "entry / #{enter_callbacks}" if enter_callbacks.present?  # TODO config entry (should use i18n)
      callbacks_list << "exit / #{exit_callbacks}" if exit_callbacks.present?  # TODO config exit (should use i18n)
      label = "{#{state.display_name}|#{callbacks_list.join('\l')}}"

      node = @graph.add_nodes(state.name.to_s, label: label)

      if state.options.fetch(:initial, false)
        @graph.add_edges(start_node, node)

      elsif state.options.fetch(:final, false)
        @graph.add_edges(node, end_node)

      end
    end


    def render_event(event)
      event.transitions.each do |transition|
        chunks = [event.name]

        chunks << render_guard(transition.options.fetch(:guard, nil))

        chunks << render_callbacks(get_callbacks(transition.options, TRANSITION_CALLBACKS))

        label = " #{chunks.join(' ')} "

        @graph.add_edges(transition.from.to_s, transition.to.to_s, label: label)
      end
    end


    def render_guard(guard)
      guard.present? ? "[#{guard}]" : ''
    end


    def render_callbacks(callbacks)
      callbacks.present? ? '/ ' << callbacks : ''
    end


    # ----------------------
    # configuration

    def init_config

      @default_config = {
          formats: GraphViz::Constants::FORMATS,

          graph_style: {
              rankdir: :TB,
          },

          node_style: {
              shape: :Mrecord,
              fontname: 'Arial',
              fontsize: 10,
              penwidth: 0.7,
          },

          edge_style: {
              dir: :forward,
              fontname: 'Arial',
              fontsize: 9,
              penwidth: 0.7,
          },

          start_node_style: {
              shape: :doublecircle,
              label: 'start',
              #style: :filled,
              color: 'black',
              fontsize: 8,
              #fillcolor: 'black',
              fixedsize: true,
              width: 0.3,
              height: 0.3,
          },

          end_node_style: {
              shape: :doublecircle,
              label: '',
              style: :filled,
              color: 'black',
              fillcolor: 'black',
              fixedsize: true,
              width: 0.20,
              height: 0.20,
          },

          transition_table_node_style: {
              shape: :plaintext
          }

      }

    end


  end
end

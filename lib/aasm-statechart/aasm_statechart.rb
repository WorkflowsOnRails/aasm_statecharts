require 'graphviz'


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

    FORMATS = GraphViz::Constants::FORMATS

    GRAPH_STYLE = {
        rankdir: :TB,
    }

    NODE_STYLE = {
        shape: :Mrecord,
        fontname: 'Arial',
        fontsize: 10,
        penwidth: 0.7,
    }

    EDGE_STYLE = {
        dir: :forward,
        fontname: 'Arial',
        fontsize: 9,
        penwidth: 0.7,
    }

    START_NODE_STYLE = {
        shape: :doublecircle,
        label: 'start',
        #style: :filled,
        color: 'black',
        fontsize: 8,
        #fillcolor: 'black',
        fixedsize: true,
        width: 0.3,
        height: 0.3,
    }

    END_NODE_STYLE = {
        shape: :doublecircle,
        label: '',
        style: :filled,
        color: 'black',
        fillcolor: 'black',
        fixedsize: true,
        width: 0.20,
        height: 0.20,
    }

    ENTER_CALLBACKS = [:before_enter, :enter, :after_enter, :after_commit]
    EXIT_CALLBACKS = [:before_exit, :exit, :after_exit]
    TRANSITION_CALLBACKS = [:before, :on_transition, :after]


    def initialize(klass)
      @start_node = nil
      @end_node = nil

      @graph = GraphViz.new(:statechart)
      @graph.type = 'digraph'

      # ruby-graphviz is missing an API to set styles in bulk, so set them here
      GRAPH_STYLE.each { |k, v| @graph.graph[k] = v }
      NODE_STYLE.each { |k, v| @graph.node[k] = v }
      EDGE_STYLE.each { |k, v| @graph.edge[k] = v }


      if !(klass.respond_to? :aasm)
        raise NoAASM_Error, "ERROR: #{klass.name} does not include AASM.  No diagram generated."
      else
        if klass.aasm.states.empty?
          raise NoStates_Error, "ERROR: No states found for #{klass.name}!  No diagram generated"
        else
          klass.aasm.states.each { |state| render_state(state) }
          klass.aasm.events.each { |event| render_event(event) unless event.blank? }
        end
      end

    end


    def save(filename, format: 'png')
      @graph.output({format => filename})
    end


    def graph
      @graph
    end


    def start_node
      if @start_node.nil?
        @start_node = @graph.add_nodes(SecureRandom.uuid, **START_NODE_STYLE)
      end

      @start_node
    end


    def end_node
      if @end_node.nil?
        @end_node = @graph.add_nodes(SecureRandom.uuid, **END_NODE_STYLE)
      end

      @end_node
    end


    #------
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


    def render_state(state)
      enter_callbacks = get_callbacks(state.options, ENTER_CALLBACKS)
      exit_callbacks = get_callbacks(state.options, EXIT_CALLBACKS)

      callbacks_list = []
      callbacks_list << "entry / #{enter_callbacks}" if enter_callbacks.present?
      callbacks_list << "exit / #{exit_callbacks}" if exit_callbacks.present?
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

        guard = transition.options.fetch(:guard, nil)

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
  end
end

#
#
# @author Brendan MacDonell

require 'graphviz'


module AasmStatechart
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
      shape: :circle,
      label: '',
      style: :filled,
      color: 'black',
      fillcolor: 'black',
      fixedsize: true,
      width: 0.25,
      height: 0.25,
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

      klass.aasm.states.each { |state| render_state(state) }
      klass.aasm.events.each { |name, event| render_event(name, event) }
    end

    def save(filename, format: 'png')
      @graph.output({format => filename})
    end

    private

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

    def render_event(name, event)
      event.transitions.each do |transition|
        chunks = [name]

        guard = transition.options.fetch(:guard, nil)
        chunks << "[#{guard}]" if guard
        callbacks = get_callbacks(transition.options, TRANSITION_CALLBACKS)
        chunks << '/' << callbacks if callbacks.present?

        label = " #{chunks.join(' ')}  "

        @graph.add_edges(transition.from.to_s, transition.to.to_s, label: label)
      end
    end
  end
end

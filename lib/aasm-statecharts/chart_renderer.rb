require 'graphviz'
require_relative 'transition_table'
require_relative 'version'

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


  class Chart_Renderer

    FORMATS = GraphViz::Constants::FORMATS

    attr :default_config

    @CONF = {}

    ENTER_CALLBACKS = [:before_enter, :enter, :after_enter, :after_commit]
    EXIT_CALLBACKS = [:before_exit, :exit, :after_exit]

    TRANSITION_CALLBACKS = [:before, :on_transition, :after]

    TRANSITION_GUARDS = [:guards, :guard, :if]


    def initialize(klass, transition_table=false, config_options = {})

      init_config config_options

      @start_node = nil
      @end_node = nil

      @graph = GraphViz.new(:statechart)
      @graph.type = 'digraph' # TODO config


      @transition_table = TransitionTable.new(@default_config.fetch(:transition_table_table_style, {})) if transition_table


      # ruby-graphviz is missing an API to set global styles (in bulk), so set them here

      @default_config[:graph_style].each { |k, v| @graph.graph[k] = v }
      @default_config[:node_style].each { |k, v| @graph.node[k] = v }
      @default_config[:edge_style].each { |k, v| @graph.edge[k] = v }


      if !(klass.respond_to? :aasm)
        raise NoAASM_Error, "ERROR: #{klass.name} does not include AASM.  No diagram generated."

      else

        if klass.aasm.states.empty?
          raise NoStates_Error, "ERROR: No states found for #{klass.name}!  No diagram generated"
        else

          add_graph_title_node(humanize_class_name(klass.name))

          klass.aasm.states.each { |state| render_state(state) }
          klass.aasm.events.each { |event| render_event(event) unless event.blank? }

          if transition_table
            klass.aasm.events.each do |event|
              unless event.blank?
                event.transitions.each { |t| @transition_table.add_transition(t, conditionals: transition_guards(t)) }
              end
            end

            transition_node_opts = @default_config[:transition_table_node_style].merge({ label: @transition_table.render })

            @graph.add_nodes('State Transition Table', transition_node_opts) # TODO i18n table title or at least config

          end

          add_graph_footer_node

        end
      end

    end


    def save(filename, format: 'png', graph_options: (@default_config[:graph_style]))
      opts = {}
      opts.merge!(graph_options).merge({ format => filename }) # FIXME why can't I merge in graph_options? can't seem to use opts
      @graph.output({ format => filename })
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


    def get_callbacks(options, keys, join_str = ' ')
      get_options(options, keys)
          .map { |callback| "#{callback}" }
          .join(join_str)
    end


    def transition_guards(transition)
      get_options(transition.options, TRANSITION_GUARDS)
    end


    def render_state(state)

      enter_callbacks = get_callbacks(state.options, ENTER_CALLBACKS, ', ')
      exit_callbacks = get_callbacks(state.options, EXIT_CALLBACKS, ', ')


      label = state_label(enter_callbacks, state.display_name, exit_callbacks)

      node = add_node state.name.to_s, :node_style, label

      if state.options.fetch(:initial, false)
        @graph.add_edges(start_node, node)

      elsif state.options.fetch(:final, false)
        @graph.add_edges(node, end_node)

      end
    end


    # return the label string for the state node given the name, the string for 'enter' and the string for 'exit'
    def state_label(enter_conditions, name, exit_conditions)
      # orig: "{#{state.display_name}|#{callbacks_list.join('\l')}}"


      enter_row = enter_conditions.present? ? enter_exit_td(enter_conditions.humanize(capitalize: false),
                                                            'enter state action',
                                                            @default_config[:node_enter_label_style]) : "" # TODO I18n 'enter'

      exit_row = exit_conditions.present? ? enter_exit_td(exit_conditions.humanize(capitalize: false),
                                                          'exit state action',
                                                          @default_config[:node_exit_label_style]) : "" # TODO I18n 'exit'

      state_name_row = single_td_row(name, 'BORDER="0" ALIGN="CENTER"') # TODO use config from file for ALIGN


      # Note that dot requires this all to be surrounded by an extra pair of "<>"
      '<' + make_html_entity("table", "#{enter_row} #{state_name_row} #{exit_row}", 'BORDER="0" CELLBORDER="1"') + '>'

    end


    def enter_exit_td(inner_body, enter_exit = '', style_options = {})

      cell_color = color_attr style_options.fetch(:color, 'gray')
      alignment = align_attr(style_options.fetch(:align, 'CENTER'))
      sides = side_attr(style_options.fetch(:sides, ''))

      font_attributes = font_attr(name: style_options.fetch(:fontname, 'serif'),
                                  size: style_options.fetch(:fontsize, 11),
                                  color: style_options.fetch(:fontcolor, 'gray')
      )

      single_td_row(
          make_html_entity('FONT', "#{enter_exit}: " + inner_body, font_attributes),
          sides + ' ' + alignment + ' ' + cell_color)
    end


    def font_attr(name: '', size: '', color: '')
      "#{face_attr(name)} #{point_size_attr(size)} #{color_attr(color)}"
    end


    def point_size_attr(pt_size)
      html_like_attr "POINT-SIZE", pt_size
    end


    def face_attr(face)
      html_like_attr "FACE", face
    end


    def align_attr(alignment)
      html_like_attr "ALIGN", alignment
    end


    def side_attr(sides)
      html_like_attr "SIDES", sides
    end


    def color_attr(color_name)
      html_like_attr "COLOR", color_name
    end


    # return an empty string if the value is empty
    def html_like_attr(tag, value)
      value.to_s.empty? ? "" : "#{tag}=\"#{value}\""
    end


    def single_td_row(inner_body, td_attributes='')
      make_html_entity("tr", make_html_entity("td", inner_body, td_attributes))
    end


    def make_html_entity(tag, inner_body, tag_attributes='')
      attribs = ' ' + tag_attributes unless tag_attributes.empty?
      "<#{tag}#{attribs}>#{inner_body}</#{tag}>"
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
      guard.present? ? "#{ ([] << guard).flatten }" : ''
    end


    def render_callbacks(callbacks)
      callbacks.present? ? '/ ' << callbacks : ''
    end


    # plaintext node for the graph label (like a title box)
    def add_graph_title_node(graph_label = '')

      add_node 'title', :title_node_style, "#{graph_label}\\l"

    end


    # plaintext node for the graph footer info
    def add_graph_footer_node

      text = "Date: #{Time.now.strftime '%b %d %Y - %H:%M'}\\l" +
          "Generated by #{AASM_StateChart::APP_HUMAN_NAME} #{AASM_StateChart::VERSION}\\l" + "http://github.com/weedySeaDragon"

      add_node 'footer', :footer_node_style, text

    end


    def add_node(name, default_config_key, label_text)
      @graph.add_nodes(name, @default_config[default_config_key].merge({ label: label_text }))

    end


    def humanize_class_name(klass_name)
      klass_name.gsub(/([A-Z])/, ' \1').strip
    end


    # ----------------------
    # configuration

    def init_config(config_options)

      @default_config = load_default_config

      @default_config.each do |k, v|

        @default_config[k].merge! config_options[k] if config_options.has_key?(k)
      end

      # @default_config.merge! config_options
      @default_config
    end


    def load_default_config
      {
          formats: FORMATS,

          graph_style: {
              rankdir: :TB,
          },

          node_style: {
              shape: :Mrecord,
              fontname: 'Arial',
              fontsize: 11,
              penwidth: 0.7,
          },

          node_enter_label_style: {
              fontname: 'Arial:italic',
              fontsize: 10,
              fontcolor: 'gray20',
              color: 'gray40',
              align: 'LEFT',
              sides: 'B',
          },

          node_exit_label_style: {
              fontname: 'Arial:italic',
              fontsize: 10,
              fontcolor: 'gray20',
              color: 'gray40',
              align: 'RIGHT',
              sides: 'T',
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
          },

          transition_table_table_style: {
              align: 'LEFT',
              cell_padding: 4,
              headercolor: 'black',
              fontcolor: 'blue',
          },

          title_node_style: {
              shape: :plaintext,
              fontcolor: 'black',
              fontsize: 10
          },

          footer_node_style: {
              shape: :plaintext,
              fontsize: 6,
              fontcolor: 'black'
          }

      }
    end

  end
end

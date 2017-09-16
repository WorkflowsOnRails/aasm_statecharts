#--------------------------
#
# @file transition_table.rb
#
# @desc a state transition table
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   1/11/17
#
#
#--------------------------


module AASM_StateChart


  class TransitionTable

    def initialize(config_options={})
      @rows = []
      @config = config_options
    end


    def add_transition(transition, conditionals: nil)
      t = {}
      t[:old_state] = transition.from
      t[:new_state] = transition.to
      t[:triggering_event] = transition.event.name
      t[:iff_conditions_met] = conditionals.blank? ? nil : render_conditionals(conditionals)

      @rows << t

    end


    def render
      output = '<'
      output << table_start

      output << header_row

      @rows.each { |row| output << render_row(row) }

      output << table_end

      output << '>'

      output
    end


    #======
    private


    def transition_cols_order
      [:old_state, :triggering_event, :iff_conditions_met,  :new_state, ]
    end


    def transition_headers
      # TODO use I18n lookup like aasm gem does in localizer.rb

      { old_state: 'Old State',
        new_state: 'New State',
        triggering_event: 'Triggering Event',
        iff_conditions_met: 'Iff All These Are True' }

    end


    def table_start
      "<TABLE CELLPADDING=\"#{@config.fetch(:cell_padding, 4)}\" CELLSPACING=\"0\" TITLE=\"State Transition Table\">"  # TODO get from config file; I18n
    end


    def table_end
      '</TABLE>'
    end


    def header_row()
      render_row_with(transition_headers, header_row_start, header_row_end, header_cell_start, header_cell_end)
    end


    def render_row(row)
      render_row_with(row, row_start, row_end, cell_start, cell_end)
    end


    def render_row_with(row, row_start_method, row_end_method, cell_start_method, cell_end_method)
      result = ''
      result << row_start_method
      transition_cols_order.each do |col_key|
        result << cell_start_method
        result << row[col_key].to_s
        result << cell_end_method
      end
      result << row_end_method
      result
    end


    # TODO DRY with rendering methods in chart_renderer


    def render_conditionals(conditionals, join_str=' ')
      conditionals.join(join_str)
    end


    def header_row_start
      '<TR>'
    end


    def header_row_end
      '</TR>'
    end


    def header_cell_start
      "<TD ALIGN=\"#{@config.fetch(:align, 'LEFT')}\"><FONT COLOR=\"#{@config.fetch(:headercolor, 'black')}\">"
    end


    def header_cell_end
      '</FONT></TD>'
    end


    def row_start
      '<TR>'
    end


    def row_end
      '</TR>'
    end


    def cell_start
    #  "<TD ALIGN=\"#{@config.fetch(:align, 'LEFT')}\"><FONT COLOR=\"#{@config.fetch(:fontcolor, 'black')}\">"
      "<TD ALIGN=\"#{@config.fetch(:align, 'LEFT')}\">"
    end


    def cell_end
      '</TD>' #'</FONT></TD>'
    end
  end # TransitionTable

end # module AASM_StateChart

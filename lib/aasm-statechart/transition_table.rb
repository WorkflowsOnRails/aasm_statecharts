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

    def initialize
      @rows = []
    end


    def add_transition(transition, conditionals: )
      t = {}
      t[:old_state] = transition.from
      t[:new_state] = transition.to
      t[:triggering_event] = transition.event.name
      t[:iff_conditions_met] = conditionals.blank? ? nil : render_conditionals(conditionals)

      @rows << t

    end


=begin

digraph structs {
    node [shape=plaintext]
    struct1 [label=<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR><TD>left</TD><TD PORT="f1">mid dle</TD><TD PORT="f2">right</TD></TR>
</TABLE>>];
    struct2 [label=<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR><TD PORT="f0">one</TD><TD>two</TD></TR>
</TABLE>>];
    struct3 [label=<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4">
  <TR>
    <TD ROWSPAN="3">hello<BR/>world</TD>
    <TD COLSPAN="3">b</TD>
    <TD ROWSPAN="3">g</TD>
    <TD ROWSPAN="3">h</TD>
  </TR>
  <TR>
    <TD>c</TD><TD PORT="here">d</TD><TD>e</TD>
  </TR>
  <TR>
    <TD COLSPAN="3">f</TD>
  </TR>
</TABLE>>];
    struct1:f1 -> struct2:f0;
    struct1:f2 -> struct3:here;
}

=end


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
      [:old_state, :new_state, :triggering_event, :iff_conditions_met]
    end


    def transition_headers
      # TODO use I18n lookup like aasm gem does in localizer.rb
      # TODO could read these table headers from a configuration file

      {old_state: 'Old State',
       new_state: 'New State',
       triggering_event: 'Triggering Event',
       iff_conditions_met: 'Only If All These Are True'}

    end


    def table_start
      '<TABLE CELLPADDING="2" CELLSPACING="0" TITLE="State Transition Table">'
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


    def render_conditionals(conditionals)

      conditionals.join(' ')

    end

    def header_row_start
      '<TR>'
    end


    def header_row_end
      '</TR>'
    end


    def header_cell_start
      '<TD>'
    end


    def header_cell_end
      '</TD>'
    end


    def row_start
      '<TR>'
    end


    def row_end
      '</TR>'
    end


    def cell_start
      '<TD>'
    end


    def cell_end
      '</TD>'
    end
  end # TransitionTable

end # module AASM_StateChart

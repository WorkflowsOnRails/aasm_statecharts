require 'graphviz/constants'

#--------------------------
#
# @file graphviz_options.rb
#
# @desc A simple stoopid class that gets options from graphViz and can spit them out
#
# @author Ashley Engelund (ashley@ashleycaroline.com  weedySeaDragon @ github)
# @date   1/26/17
#
#
#--------------------------

module AASM_StateChart


  class GraphvizOptions

    ALL_ATTRIBS_TITLE = 'All attribute groups'
    GRAPH_ATTRIBS_TITLE = 'Graph attributes:'
    NODE_ATTRIBS_TITLE = 'Node attributes:'
    GV_TYPES_ATTRIBS_TITLE = 'GraphViz types:'
    EDGE_ATTRIBS_TITLE = 'Edge attributes:'
    COLORS_ATTRIBS_TITLE = 'Colors:'
    PROGRAMS_ATTRIBS_TITLE = 'Programs:'
    GRAPHTYPE_ATTRIBS_TITLE = 'Graph Types:'
    FORMAT_ATTRIBS_TITLE = 'File Formats:'


    def self.dump_attribs(option)

      gv_colors = {'named colors': GraphViz::Utils::Colors::COLORS}
      gv_formats = {'output file formats': GraphViz::Constants::FORMATS}
      gv_programs = {'programs to process dot file': GraphViz::Constants::PROGRAMS}
      gv_graphtype = {'graph types': GraphViz::Constants::GRAPHTYPE}

      # @url http://www.graphviz.org/content/arrow-shapes
      #gv_arrowshapes = {'Shapes': ['box', 'crow', 'curve', 'icurve', 'diamond', 'dot', 'inv', 'none', 'normal', 'tee', 'vee'],
      #                  'modifiers': ['o', 'l', 'r']}

      # @url http://www.graphviz.org/content/color-names
      #gv_color_schemes = {}

      # TODO friendlize: put into the format for config.yml.  Explain the keys and some values

      # node shapes and info @url http://www.graphviz.org/content/node-shapes

      #gv_types_info = {
      #    EscString: 'a string',
      #    GvDouble: 'decimal point number (double)',
      #    GvBool: 'boolean (true or false)',
      #    Color: "one of the accepted color names, or the hex code WITHOUT the '#'",
      #    ArrowType: "one of the arrow shapes with optional modifiers",
      #    Rect: "???",
      #    SplineType: "???",
      #    LblString: "??? label string?  <gv>STRING</gv>",
      #    HtmlString: " a string surrounded by '<' and '>' (prepended with '<' and appended with '>')"
      #}


      config_hash = case option

                      when :all
                        title_with_hash ALL_ATTRIBS_TITLE,
                                        graphviz_options_for(/G|S|X/)
                                            .merge(graphviz_options_for(/N/))
                                            .merge(graphviz_options_for(/E/))
                                            .merge(gv_colors)
                                            .merge({'Formats': gv_formats})
                                            .merge({'Programs': gv_programs})
                                            .merge({'Graph Types': gv_graphtype})

                      when :graph
                        self.title_with_hash GRAPH_ATTRIBS_TITLE, graphviz_options_for(/G|S|X/)

                      when :nodes
                        self.title_with_hash NODE_ATTRIBS_TITLE, graphviz_options_for(/N/)

                      when :edges
                        self.title_with_hash EDGE_ATTRIBS_TITLE, graphviz_options_for(/E/)

                      when :colors
                        self.title_with_hash COLORS_ATTRIBS_TITLE, gv_colors

                      when :formats
                        self.title_with_hash FORMAT_ATTRIBS_TITLE, gv_formats # Array

                      when :programs
                        self.title_with_hash PROGRAMS_ATTRIBS_TITLE, gv_programs # Array

                      when :graphtype
                        self.title_with_hash GRAPHTYPE_ATTRIBS_TITLE, gv_graphtype # Array
                      else
                        {}
                    end

      config_hash.pretty_inspect
    end


    private

    def self.title_with_hash(title, hash)
      {'Title': title, 'values': hash}
    end



    def self.graphviz_options_for(regex)
      GraphViz::Constants::getAttrsFor(regex)
    end


  end # GraphvizOptions


end



require 'graphviz'
require 'pp'


# Use these tasks to build a complete config.yml file with all options for everything

# from graphviz/constants.rb:
#   E, N, G, S and C represent edges, nodes, the root graph, subgraphs and cluster subgraphs, respectively

desc "pp Hash of GraphViz options for Graphs"
task :pp_graphviz_graph_options do
  # gets constants for the root graph, subgraphs, and cluster subgraphs (G|S|X):
  pp graphviz_options_for(/G|S|X/)
end


desc "pp Hash of GraphViz options for Nodes"
task :pp_graphviz_node_options do
  # gets constants for nodes (N):
  pp graphviz_options_for(/N/)
end


desc "pp Hash of GraphViz options for Edges"
task :pp_graphviz_edge_options do
  # gets constants for edges (E):
  pp graphviz_options_for(/E/)
end

desc "GraphViz color names"
task :graphviz_colors do
  pp GraphViz::Utils::Colors::COLORS
end


def graphviz_options_for(regex)
  GraphViz::Constants::getAttrsFor(regex)
end


=begin

to call a Rake task:

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rake'

rake_app = Rake.application

rake_app.init
rake_app.load_rakefile

# load any other .rake files:
rake_app.add_import 'some/other/file.rake'

rake_app[:task_name].invoke

# to run the task again, you must re-enable it:
rake_app[:task_name].reenable
rake_app[:task_name].invoke

=end
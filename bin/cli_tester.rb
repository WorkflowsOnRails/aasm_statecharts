require '../lib/aasm-statecharts/aasm_state_charts'
load 'aasm_statecharts'


# ["-#{arg_info[:short]}", "#{arg_info[:option]}", "#{arg_info[:model]}"]

AASM_StateChart::AASM_Statecharts_CLI.new(['-a'])
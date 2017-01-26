require '../lib/aasm-statecharts/aasm_state_charts'
load 'aasm_statecharts'


# ["-#{arg_info[:short]}", "#{arg_info[:option]}", "#{arg_info[:model]}"]

FileUtils.cd (File.expand_path('~/github/AV--shf-project/app/models'))

AASM_StateChart::AASM_Statecharts_CLI.new(["-d", "./docs", "-i", "../app/models" "membership_application"])
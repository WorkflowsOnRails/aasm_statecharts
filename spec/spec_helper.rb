Bundler.require(:default, :development)

SimpleCov.start do
  add_filter "/spec/"
end

require_relative '../lib/aasm_statechart'

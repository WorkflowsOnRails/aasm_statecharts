require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require 'rspec'

require 'aasm'
require 'active_record'

require_relative '../lib/aasm_statecharts'

Dir[File.join(__dir__, 'fixtures','*.rb')].each { |file| require file }

Dir[File.join(__dir__, 'support','*.rb')].each { |file| require file }


OUT_DIR = './spec/spec-out'

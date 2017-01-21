require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require 'rspec'

require 'aasm'
require 'active_record'


require File.absolute_path(File.join(__dir__, '..', 'lib','aasm_statecharts.rb'))


Dir[File.join(__dir__, 'fixtures','*.rb')].each { |file| require file }

Dir[File.join(__dir__, 'support','*.rb')].each { |file| require file }


OUT_DIR = './spec/spec-out'

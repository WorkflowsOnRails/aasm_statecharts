require 'simplecov'

SimpleCov.start do
  add_filter "/spec/"
end

require 'rspec'

require 'aasm'

require 'graphviz'

#require 'active_record'

require File.expand_path(File.join(__dir__, '..', 'lib','aasm_statecharts.rb'))


#Dir[File.join(__dir__, 'fixtures','*.rb')].each { |file| require file }

Dir[File.join(__dir__, 'support','*.rb')].each { |file| require file }



def rm_specout_outfile(outfile = "#{DEFAULT_MODEL}.png")
  fullpath = File.join(OUT_DIR, outfile)
  # FileUtils.rm fullpath if File.exist? fullpath
  # puts "     (cli_spec: removed #{fullpath})"
end



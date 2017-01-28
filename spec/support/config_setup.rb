#module ConfigSetup

require 'psych'

OUT_DIR = './spec/spec-out'

Dir.mkdir(OUT_DIR) unless Dir.exist? OUT_DIR


def config_from(fn)
  config = {}
  if File.exist? fn
    File.open fn do |cf|
      begin
        config = Psych.safe_load(cf)
      rescue Psych::SyntaxError => ex
        ex.message
      end
    end
  end

  config
end


INCLUDE_PATH = File.expand_path File.join(__dir__, '..', 'fixtures')


DEFAULT_MODEL = 'two_simple_states'


def good_options
  options = {
      all: false,
      path: INCLUDE_PATH,
      directory: OUT_DIR,
      format: 'png',
      models: [DEFAULT_MODEL],
      no_rails: false
  }
end


#- - - - - - - - - -

#end
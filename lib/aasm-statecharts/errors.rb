# errors raised

module AASM_StateChart


  class AASM_StateChart_Error < StandardError

    PREFIX = '  >>>  ERROR: '
    INDENT_SIZE = PREFIX.size
    INDENT_SPACES = ' ' * INDENT_SIZE

    def self.error_message(message = '')
      "\n\n#{PREFIX}#{message}  [#{self.name}] \n\n"
    end

    def self.indent
      INDENT_SPACES
    end

    def self.show_cause(c)
      "#{indent}#{c.class.name}  #{c.message} \n#{indent}#{c.backtrace_locations.join("\n#{indent}")}]\n\n#{indent}cause: #{c.cause}.\n\n"

    end

  end


  class CLI_Inputs_ERROR < AASM_StateChart_Error
  end

  class AASM_NoModels < AASM_StateChart_Error
  end

  class AASM_NotFound_Error < AASM_StateChart_Error
  end

  class NoAASM_Error < AASM_StateChart_Error
  end

  class NoStates_Error < AASM_StateChart_Error
  end

  class BadFormat_Error < AASM_StateChart_Error
  end

  class NoConfigFile_Error < AASM_StateChart_Error
  end

  class BadConfigFile_Error < AASM_StateChart_Error
  end

  class BadOutputDir_Error < AASM_StateChart_Error
  end

  class NoRailsConfig_Error < AASM_StateChart_Error
  end

  class BadPath_Error < AASM_StateChart_Error
  end

  class PathNotLoaded_Error < AASM_StateChart_Error
  end

  class ModelNotLoaded_Error < AASM_StateChart_Error
  end

  class RootAndSubclassSame_Error < AASM_StateChart_Error
  end

end # module

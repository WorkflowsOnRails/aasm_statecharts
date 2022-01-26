class LambdaReader
  class << self
    def source(obj)
      unless obj.class == Proc
        raise ArgumentError,
              "Wrong parameter class. Expected Lambda, got #{obj.class}."
      end
      @lambda_code_line = extract_lambda_code_line(obj.source_location)
      lambda_code = match_lambda_syntax
      lambda_code[0] unless lambda_code.nil?
    end

    private

    def extract_lambda_code_line(lambda_source_location)
      file_name = lambda_source_location.first
      line_number = lambda_source_location.last
      IO.readlines(file_name)[line_number - 1]
    end

    def match_lambda_syntax
      classic_syntax_matcher || dash_rocket_syntax_matcher || do_end_syntax_matcher
    end

    def classic_syntax_matcher
      /lambda ?{ ?\|.*\|.*}/m.match(@lambda_code_line)
    end

    def dash_rocket_syntax_matcher
      /-> ?\(?.*\)? ?{.*}/m.match(@lambda_code_line)
    end

    def do_end_syntax_matcher
      /lambda do \|?.*\|?.* end/m.match(@lambda_code_line)
    end
  end
end

module Maccro
  module CodeUtil
    def self.code_position_to_index(source, lineno, column)
      source_lines = source.lines # including newline at the end of line
      if source_lines.size < lineno
        raise "too few lines for specified position: lineno:#{lineno}, column:#{column}"
      end
      counter = 1
      index = 0
      while counter < lineno
        index += source_lines.shift.size
        counter += 1
      end
      if source_lines.empty?
        raise "too few lines for specified position: lineno:#{lineno}, column:#{column}"
      end
      # column is 0 origin
      if source_lines.first.size < 1
        raise "empty line at the end of source"
      end
      if source_lines.first.size < column + 1
        raise "too few chars in the line for specified position: lineno:#{lineno}, column:#{column}"
      end
      return index + column
    end

    def self.code_range_to_range(source, code_range)
      begin_index = code_position_to_index(source, code_range.first_lineno, code_range.first_column)
      end_index = code_position_to_index(source, code_range.last_lineno, code_range.last_column)
      Range.new(begin_index, end_index)
    end

    def self.code_range_to_code(source, code_range)
      source[code_range_to_range(source, code_range)]
    end
  end
end

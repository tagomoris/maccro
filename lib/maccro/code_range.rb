require_relative 'code_util'

module Maccro
  class CodeRange
    def self.from_node(ast)
      CodeRange.new(ast.first_lineno, ast.first_column, ast.last_lineno, ast.last_column)
    end

    attr_reader :first_lineno, :first_column, :last_lineno, :last_column

    def initialize(first_lineno, first_column, last_lineno, last_column)
      @first_lineno = first_lineno
      @first_column = first_column
      @last_lineno = last_lineno
      @last_column = last_column
    end

    def ==(other)
      @first_lineno == other.first_lineno &&
        @first_column == other.first_column &&
        @last_lineno == other.last_lineno &&
        @last_column == other.last_column
    end

    def <=>(other)
      if @first_lineno < other.first_lineno
        -1
      elsif @first_lineno == other.first_lineno
        if @first_column < other.first_column
          -1
        elsif @first_column == other.first_column
          if @last_lineno < other.last_lineno
            -1
          elsif @last_lineno == other.last_lineno
            if @last_column < other.last_column
              -1
            elsif @last_column == other.last_column
              0
            else # @last_column > other.last_column
              1
            end
          else # @last_lineno > other.last_lineno
            1
          end
        else # @first_column > other.first_column
          1
        end
      else # @first_lineno > other.first_lineno
        1
      end
    end

    def source(path)
      source = File.open(path){|f| f.read } # open as binary?
      range = CodeUtil.code_range_to_range(source, self)
      source[range]
    end
  end
end

module Maccro
  class CodeRange
    def self.from_node(path, node)
      CodeRange.new(path, ast.first_lineno, ast.first_column, ast.last_lineno, ast.last_column)
    end

    attr_reader :first_lineno, :first_column, :last_lineno, :last_column

    def initialize(path, first_lineno, first_column, last_lineno, last_column)
      @path = path
      @first_lineno = first_lineno
      @first_column = first_column
      @last_lineno = last_lineno
      @last_column = last_column
    end

    def source
      fl = @first_lineno - 1 # AST lineno is 1 origin
      ll = @last_lineno - 1
      source = File.open(@path){|f| f.read } # open as binary?
      lines = source.lines.to_a[fl..ll]
      lines[0] = lines[0][@first_column..-1]
      lines[-1] = lines[-1][0..@last_column]
      lines.join
    end
  end
end

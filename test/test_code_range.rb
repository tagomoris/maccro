require_relative "helper"
require "maccro/code_range"

class CodeRangeTest < ::Test::Unit::TestCase
  def example_method
    "to get AST node"
  end

  def e1; end; def e2; end;

  test 'from_node' do
    ast1 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:example_method))
    range1 = Maccro::CodeRange.from_node(ast1)
    assert_equal 5, range1.first_lineno
    assert_equal 2, range1.first_column
    assert_equal 7, range1.last_lineno
    assert_equal 5, range1.last_column
  end

  test 'source' do
    ast1 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:example_method))
    range1 = Maccro::CodeRange.from_node(ast1)
    code1 = <<EOC
def example_method
    "to get AST node"
  end
EOC
    assert_equal code1, range1.source(__FILE__)

    ast2 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:e1))
    range2 = Maccro::CodeRange.from_node(ast2)
    code2 = "def e1; end;"
    assert_equal code2, range2.source(__FILE__)

    ast3 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:e2))
    range3 = Maccro::CodeRange.from_node(ast3)
    code3 = "def e2; end;"
    assert_equal code3, range3.source(__FILE__)
  end

  test '==' do
    ast1 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:example_method))
    range1 = Maccro::CodeRange.from_node(ast1)

    assert_equal range1, range1
  end

  test '<=>' do
    ast1 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:example_method))
    range1 = Maccro::CodeRange.from_node(ast1)

    ast2 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:e1))
    range2 = Maccro::CodeRange.from_node(ast2)

    ast3 = RubyVM::AbstractSyntaxTree.of(CodeRangeTest.instance_method(:e2))
    range3 = Maccro::CodeRange.from_node(ast3)

    assert_equal [range1, range2, range3], [range3, range2, range1].shuffle.sort
    assert_equal 0, (range1 <=> range1)
  end
end

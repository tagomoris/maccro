require_relative "helper"
require "maccro/code_util"

class CodeUtilTest < ::Test::Unit::TestCase
  text1 = "0123456789\n0123456789\n0123456789\n0123456789\n"
  text2 = "\n\n\n\n0123456789\n1"
  text3 = "0123456789\n\n\n0123456789\n0123456789\n\n\n0123456789\n"

  data(
    case1: [text1, 0, 1, 0],
    case2: [text1, 11, 2, 0],
    case3: [text1, 16, 2, 5],
    case4: [text2, 7, 5, 3],
    case5: [text2, 15, 6, 0],
    case6: [text3, 35, 6, 0],
  )
  test 'code_position_to_index' do |data|
    source, expected_index, lineno, column = data
    assert_equal expected_index, Maccro::CodeUtil.code_position_to_index(source, lineno, column)
  end

  CodeRangeDouble = Struct.new(:first_lineno, :first_column, :last_lineno, :last_column)
  def self.range(a, b, c, d)
    CodeRangeDouble.new(a, b, c, d)
  end

  data(
    case1: [text1, 0...3, range(1, 0, 1, 3)],
    case2: [text1, 11...22, range(2, 0, 3, 0)],
    case3: [text1, 16...42, range(2, 5, 4, 9)],
    case4: [text2, 7...15, range(5, 3, 6, 0)],
    case5: [text2, 15...15, range(6, 0, 6, 0)],
    case6: [text3, 35...46, range(6, 0, 8, 9)],
  )
  test 'code_range_to_range' do |data|
    source, expected_range, code_range = data
    assert_equal expected_range, Maccro::CodeUtil.code_range_to_range(source, code_range)
  end

  data(
    case1: [text1, "012", range(1, 0, 1, 3)],
    case2: [text1, "0123456789\n", range(2, 0, 3, 0)],
    case3: [text1, "56789\n0123456789\n012345678", range(2, 5, 4, 9)],
    case4: [text2, "3456789\n", range(5, 3, 6, 0)],
    case5: [text2, "", range(6, 0, 6, 0)],
    case6: [text3, "\n\n012345678", range(6, 0, 8, 9)],
  )
  test 'code_range_to_code' do |data|
    source, expected_source, code_range = data
    assert_equal expected_source, Maccro::CodeUtil.code_range_to_code(source, code_range)
  end

  def get_range_example
    "e"
  end

  def self.get_range_example
    "e"
  end

  test 'get_method_range for instance method' do
    method = CodeUtilTest.instance_method(:get_range_example)
    method_node = RubyVM::AbstractSyntaxTree.of(method)
    tree = RubyVM::AbstractSyntaxTree.parse(File.read(__FILE__))

    node = Maccro::CodeUtil.get_method_node(tree, :get_range_example, method_node.first_lineno, method_node.first_column)
    assert_not_nil node
    assert_equal :get_range_example, node.children[0]
    assert_equal node.last_lineno, method_node.last_lineno
    assert_equal node.last_column, method_node.last_column
  end

  test 'get_method_range for singleton method' do
    method = CodeUtilTest.singleton_method(:get_range_example)
    method_node = RubyVM::AbstractSyntaxTree.of(method)
    tree = RubyVM::AbstractSyntaxTree.parse(File.read(__FILE__))

    node = Maccro::CodeUtil.get_method_node(tree, :get_range_example, method_node.first_lineno, method_node.first_column, singleton_method: true)
    assert_not_nil node
    assert_equal :get_range_example, node.children[1]
    assert_equal node.last_lineno, method_node.last_lineno
    assert_equal node.last_column, method_node.last_column
  end
end

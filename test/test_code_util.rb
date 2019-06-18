require_relative "helper"
require "maccro/code_util"
require "maccro/code_range"

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

  data(
    no_args_1: ['{x.to_s}', '->{x.to_s}'],
    no_args_2: ['{ x.to_s }', '->{ x.to_s }'],
    one_arg_1: ['{|x| x.to_s }', '->(x){ x.to_s }'],
    one_arg_2: ['{ |x| x.to_s }', '->(x){ x.to_s }'],
    one_arg_3: ['{ |x|x.to_s }', '->(x){x.to_s }'],
    two_args_1: ['{|a,b| a + b }', '->(a,b){ a + b }'],
    two_args_2: ['{|a, b| a + b }', '->(a, b){ a + b }'],
    two_args_3: ['{ |a, b| a + b }', '->(a, b){ a + b }'],
    any_args_1: ['{|*list| list.size }', '->(*list){ list.size }'],
  )
  test 'convert_scope_to_lambda' do |data|
    scope_source, lambda_source = data
    assert_equal lambda_source, Maccro::CodeUtil.convert_scope_to_lambda(scope_source)
  end

  def get_range_example
    "e"
  end

  def self.get_range_example
    "e"
  end

  class Receiver
    def to_s
      "r"
    end
  end

  module Example
    def self.lambda_1
      lambda { |x| x.to_s }
    end

    def self.lambda_2
      lambda{|x| x.to_s }
    end

    def self.lambda_literal_1
      ->(x){ x.to_s }
    end

    def self.lambda_literal_2
      -> (x) { x.to_s }
    end

    def self.kernel_lambda
      Kernel.lambda{|x| x.to_s }
    end

    def self.proc_1
      proc { |x| x.to_s }
    end

    def self.proc_2
      proc{|x| x.to_s }
    end

    def self.kernel_proc
      Kernel.proc{|x| x.to_s }
    end

    def self.proc_new
      Proc.new{|x| x.to_s }
    end

    def self.get_block(&block)
      block
    end

    def self.block_parameter
      get_block{|x| x.to_s }
    end
  end

  data(
    case1: [:lambda_1, :ITER, "lambda { |x| x.to_s }"],
    case2: [:lambda_2, :ITER, "lambda{|x| x.to_s }"],
    case3: [:lambda_literal_1, :LAMBDA, "->(x){ x.to_s }"],
    case4: [:lambda_literal_2, :LAMBDA, "-> (x) { x.to_s }"],
    case5: [:kernel_lambda, :ITER, "Kernel.lambda{|x| x.to_s }"],
    case6: [:proc_1, :ITER, "proc { |x| x.to_s }"],
    case7: [:proc_2, :ITER, "proc{|x| x.to_s }"],
    case8: [:kernel_proc, :ITER, "Kernel.proc{|x| x.to_s }"],
    case9: [:proc_new, :ITER, "Proc.new{|x| x.to_s }"],
    case10: [:block_parameter, :SCOPE, "{|x| x.to_s }"],
  )
  test 'get_proc_node' do |data|
    example_method_name, expected_node_type, expected_code = data
    pr = Example.send(example_method_name) rescue nil
    proc_node = RubyVM::AbstractSyntaxTree.of(pr)
    tree = RubyVM::AbstractSyntaxTree.parse(File.read(__FILE__))

    node = Maccro::CodeUtil.get_proc_node(tree, proc_node.first_lineno, proc_node.first_column)
    assert_not_nil node
    assert_equal expected_node_type, node.type
    assert_equal expected_code, Maccro::CodeUtil.code_range_to_code(File.read(__FILE__), Maccro::CodeRange.from_node(node))
  end

  test 'get_method_range for instance method' do
    method = CodeUtilTest.instance_method(:get_range_example)
    method_node = RubyVM::AbstractSyntaxTree.of(method)
    tree = RubyVM::AbstractSyntaxTree.parse(File.read(__FILE__))

    node = Maccro::CodeUtil.get_method_node(tree, :get_range_example, method_node.first_lineno, method_node.first_column)
    assert_not_nil node
    assert_equal :get_range_example, node.children[0]
    assert_equal method_node.last_lineno, node.last_lineno
    assert_equal method_node.last_column, node.last_column
  end

  test 'get_method_range for singleton method' do
    method = CodeUtilTest.singleton_method(:get_range_example)
    method_node = RubyVM::AbstractSyntaxTree.of(method)
    tree = RubyVM::AbstractSyntaxTree.parse(File.read(__FILE__))

    node = Maccro::CodeUtil.get_method_node(tree, :get_range_example, method_node.first_lineno, method_node.first_column, singleton_method: true)
    assert_not_nil node
    assert_equal :get_range_example, node.children[1]
    assert_equal method_node.last_lineno, node.last_lineno
    assert_equal method_node.last_column, node.last_column
  end
end

require_relative "../helper"
require "maccro/dsl/node"
require "maccro/code_range"

class DSLNodeTest < ::Test::Unit::TestCase
  def example_method
    1 || v1
  end

  def matchee_method
    1 || x
  end

  def extend_tree_with_wrapper(tree)
    return unless tree.is_a?(RubyVM::AbstractSyntaxTree::Node)
    tree.extend Maccro::DSL::ASTNodeWrapper unless tree.is_a?(Maccro::DSL::ASTNodeWrapper)
    tree.children.each do |c|
      extend_tree_with_wrapper(c)
    end
  end

  sub_test_case 'ASTNodeWrapper' do
    test 'children returns an object, without recreation' do
      node = parse_to_ast('1 || e1').children[2]
      extend_tree_with_wrapper(node)

      assert_kind_of Array, node.children
      oid = node.children.object_id
      assert_equal oid, node.children.object_id
    end

    test 'to_code_range returns the range of the code' do
      node = proc_to_ast(DSLNodeTest.instance_method(:example_method)).children[2]
      extend_tree_with_wrapper(node)

      assert_kind_of Maccro::CodeRange, node.to_code_range

      r = node.to_code_range
      assert_equal 7, r.first_lineno
      assert_equal 4, r.first_column
      assert_equal 7, r.last_lineno
      assert_equal 11, r.last_column
    end

    test 'match? matches to just same AST' do
      node = proc_to_ast(DSLNodeTest.instance_method(:example_method)).children[2]
      extend_tree_with_wrapper(node)

      assert_true node.match?(node)

      node2 = proc_to_ast(DSLNodeTest.instance_method(:example_method)).children[2]
      extend_tree_with_wrapper(node2)
      assert_true node.match?(node2)
    end

    class VcallNode < ::Maccro::DSL::Node
      def type
        :VCALL
      end
    end

    test 'capture catches the code range of target node' do
      node = proc_to_ast(DSLNodeTest.instance_method(:example_method)).children[2]
      extend_tree_with_wrapper(node)

      original_vcall_node = node.children[1]
      assert_equal :VCALL, original_vcall_node.type
      assert_equal :v1, original_vcall_node.children[0]
      assert_equal 7, original_vcall_node.first_lineno
      assert_equal 9, original_vcall_node.first_column
      assert_equal 7, original_vcall_node.last_lineno
      assert_equal 11, original_vcall_node.last_column

      r0 = ::Maccro::CodeRange.new(7, 9, 7, 11)
      vcall_node = VcallNode.new(:v1, r0)

      assert_equal :v1, vcall_node.name
      assert_equal r0, vcall_node.to_code_range
      assert_equal [], vcall_node.children

      node.children[1] = vcall_node

      matchee = proc_to_ast(DSLNodeTest.instance_method(:matchee_method)).children[2]
      extend_tree_with_wrapper(matchee)

      assert_true node.match?(matchee)
      placeholders = {}
      node.capture(matchee, placeholders)

      assert_equal 1, placeholders.size
      assert_equal [:v1], placeholders.keys
      assert_equal ::Maccro::CodeRange.new(11, 9, 11, 10), placeholders[:v1]
    end
  end
end

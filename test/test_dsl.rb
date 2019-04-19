require_relative "helper"
require "maccro/dsl"
require "maccro/dsl/node"
require "maccro/dsl/value"
require "maccro/dsl/expression"

class DSLTest < ::Test::Unit::TestCase
  test 'placeholder_name? returns false for non-placeholder names' do
    assert_false Maccro::DSL.placeholder_name?(:name)
    assert_false Maccro::DSL.placeholder_name?(:value)
    assert_false Maccro::DSL.placeholder_name?(:f)
    assert_false Maccro::DSL.placeholder_name?(:f1)
  end

  test 'placeholder_name? returns true for expression placeholders' do
    [:e1, :e2, :e3, :e4, :e5, :e6, :e7, :e8, :e9, :e10, :e11, :e1001].each do |x|
      assert_true Maccro::DSL.placeholder_name?(x)
    end
    assert_false Maccro::DSL.placeholder_name?(:e)
    assert_false Maccro::DSL.placeholder_name?(:e0)
  end

  test 'placeholder_name? returns true fro variable placeholders' do
    [:v1, :v2, :v3, :v4, :v5, :v6, :v7, :v8, :v9, :v10, :v11, :v1001].each do |x|
      assert_true Maccro::DSL.placeholder_name?(x)
    end
  end

  def ast_node(target)
    m = proc_to_ast(target).children[2]
    m.extend Maccro::DSL::ASTNodeWrapper
    m
  end

  test 'placeholder_to_matcher_node returns matchers' do
    assert_kind_of Maccro::DSL::Value, Maccro::DSL.placeholder_to_matcher_node(ast_node(->(){ v1 }))
    assert_kind_of Maccro::DSL::Expression, Maccro::DSL.placeholder_to_matcher_node(ast_node(->(){ e1 }))

    assert_kind_of Maccro::DSL::String, Maccro::DSL.placeholder_to_matcher_node(ast_node(->(){ s1 }))
    assert_kind_of Maccro::DSL::Symbol, Maccro::DSL.placeholder_to_matcher_node(ast_node(->(){ y1 }))
    assert_kind_of Maccro::DSL::Number, Maccro::DSL.placeholder_to_matcher_node(ast_node(->(){ n1 }))
    assert_kind_of Maccro::DSL::RegularExpression, Maccro::DSL.placeholder_to_matcher_node(ast_node(->(){ r1 }))
  end

  sub_test_case 'ast_node_to_dsl_node' do
    test 'value' do
      ast = proc_to_ast(->(){ 1 || v1 })
      node = Maccro::DSL::ast_node_to_dsl_node(ast)

      n = node
      assert_equal :SCOPE, n.type
      assert_kind_of Maccro::DSL::ASTNodeWrapper, n

      n = node.children[2]
      assert_equal :OR, n.type
      assert_kind_of Maccro::DSL::ASTNodeWrapper, n
      assert_equal :LIT, n.children[0].type
      assert_kind_of Maccro::DSL::ASTNodeWrapper, n.children[0]
      assert_kind_of Maccro::DSL::Value, n.children[1]
      assert_equal "v1", n.children[1].name
    end

    test 'number or symbol' do
      ast = proc_to_ast(->(){ n1 || y1 })
      node = Maccro::DSL::ast_node_to_dsl_node(ast)

      n = node
      assert_equal :SCOPE, n.type
      assert_kind_of Maccro::DSL::ASTNodeWrapper, n

      n = node.children[2]
      assert_equal :OR, n.type
      assert_kind_of Maccro::DSL::ASTNodeWrapper, n
      assert_kind_of Maccro::DSL::Number, n.children[0]
      assert_equal "n1", n.children[0].name
      assert_kind_of Maccro::DSL::Symbol, n.children[1]
      assert_equal "y1", n.children[1].name
    end
  end

  sub_test_case 'matcher' do
    test 'matcher' do
      node = Maccro::DSL.matcher('1 || v1')
    
      n = node
      assert_equal :OR, n.type
      assert_kind_of Maccro::DSL::ASTNodeWrapper, n
      assert_equal :LIT, n.children[0].type
      assert_kind_of Maccro::DSL::ASTNodeWrapper, n.children[0]
      assert_kind_of Maccro::DSL::Value, n.children[1]
      assert_equal "v1", n.children[1].name
    end
  end
end

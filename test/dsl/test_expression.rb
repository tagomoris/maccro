require_relative "../helper"
require "maccro/dsl/expression"
require "maccro/dsl"

class ExpressionTestCase < ::Test::Unit::TestCase
  def v0
    _a = if x1 || x2
          "1or2"
         else
           nil
         end
  end

  def v1 
    _a = begin
           "yay"
         rescue
           "foo"
         end
  end

  def v2
    _a = 1 || 2
  end

  def v3
    _a = foo(1)
  end

  def v4
    _a = f
  end

  def v5
    _a = super(1, 2)
  end

  def v6
    _a = yield 1
  end

  def v7
    _a = "str" =~ /str/
  end

  def v8
    _a = defined? x
  end

  MATCHER = Maccro::DSL.matcher('_a = e1')

  test 'matcher is constructed' do
    assert_kind_of Maccro::DSL::Expression, MATCHER.children[1]
    assert_equal "e1", MATCHER.children[1].name
  end

  data(
    "if" => [:v0, "if x1 || x2\n          \"1or2\"\n         else\n           nil\n         end"],
    # "rescue" => [:v1, "begin\n           \"yay\"\n         rescue\n           \"foo\"\n         end"],
    "or" => [:v2, "1 || 2"],
    "func" => [:v3, "foo(1)"],
    "vcall" => [:v4, "f"],
    "super" => [:v5, "super(1, 2)"],
    "yield" => [:v6, "yield 1"],
    "match" => [:v7, "\"str\" =~ /str/"],
    "defined" => [:v8, "defined? x"],
  )
  test 'expression matches to an expression'do |data|
    method_name, captured_source = data
    ast = proc_to_ast(ExpressionTestCase.instance_method(method_name)).children[2]
    extend_tree_with_wrapper(ast)
    
    assert_true MATCHER.match?(ast)
    pairs = {}
    MATCHER.capture(ast, pairs)
    assert_equal 1, pairs.size
    assert_equal captured_source, pairs["e1"].source(__FILE__)
  end
end

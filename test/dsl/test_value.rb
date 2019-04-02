require_relative "../helper"
require "maccro/dsl/value"
require "maccro/dsl"

class ValueTestCase < ::Test::Unit::TestCase
  def v0
    myfunc(1 || :x)
  end

  def v1
    myfunc(1 || [10])
  end

  def v2
    myfunc(1 || {x: 1})
  end

  def v3
    myfunc(1 || ->(){ 1 })
  end

  def v4
    myfunc(1 || 2)
  end

  def v5
    myfunc(1 || nil)
  end

  def v6
    myfunc(1 || "data")
  end

  CONST_YAY = "yay"

  def v7
    myfunc(1 || CONST_YAY)
  end

  def v8(x)
    myfunc(1 || x)
  end

  def v9
    myfunc(1 || $yay)
  end

  def v10
    myfunc(1 || @yay)
  end

  MATCHER = Maccro::DSL.matcher('1 || v1')

  test 'matcher is constructed' do
    assert_kind_of Maccro::DSL::Value, MATCHER.children[1]
    assert_equal "v1", MATCHER.children[1].name
  end

  data(
    "symbol" => [:v0, ":x"],
    "array" => [:v1, "[10]"],
    "hash" => [:v2, "{x: 1}"],
    "lambda" => [:v3, "->(){ 1 }"],
    "number" => [:v4, "2"],
    "nil" => [:v5, "nil"],
    "string" => [:v6, '"data"'],
    "constant" => [:v7, "CONST_YAY"],
    "local variable" => [:v8, "x"],
    "gloval variable" => [:v9, "$yay"],
    "instance variable" => [:v10, "@yay"],
  )
  test 'value matches to a value'do |data|
    method_name, captured_source = data
    ast = proc_to_ast(ValueTestCase.instance_method(method_name)).children[2]
    extend_tree_with_wrapper(ast)
    # (FCALL@7:4-7:19 :myfunc
    #  (ARRAY@7:11-7:18
    #   (OR@7:11-7:18
    #    (LIT@7:11-7:12 1)
    #    (LIT@7:16-7:18 :x)
    #   )
    #   nil)
    # )
    or_node = ast.children[1].children[0]
    assert_true MATCHER.match?(or_node)
    pairs = {}
    MATCHER.capture(or_node, pairs)
    assert_equal 1, pairs.size
    assert_equal captured_source, pairs["v1"].source(__FILE__)
  end
end

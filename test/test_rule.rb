require_relative "helper"
require "maccro/rule"
require "maccro/code_range"

class RuleTestCase < ::Test::Unit::TestCase
  EXAMPLE_PATH = File.join(__dir__, "examples", "method_examples.rb")
  suppress_warning do
    require_relative "examples/method_examples"
  end

  def range(a, b, c, d)
    Maccro::CodeRange.new(a, b, c, d)
  end

  RULE1 = Maccro::Rule.new(:one_or_v, '1 || v1', '2 || v1')
  RULE2 = Maccro::Rule.new(:one_or_e, '1 || e1', '2 || e1')
  RULE3 = Maccro::Rule.new(:connecting_littler_than, 'e1 < e2 < e3 < e4', 'e1 < e2 && e2 < e3 && e3 < e4')

  sub_test_case 'find_placeholder_code_ranges' do
    test 'for toplevel placeholder' do
      ast = parse_to_ast('e1').children[2]
      extend_tree_with_wrapper(ast)
      assert_equal [range(1, 0, 1, 2)], Maccro::Rule.find_placeholder_code_ranges(ast, 'e1')
    end

    test 'for some same placeholders' do
      ast = parse_to_ast('e1 && e2 || e1').children[2]
      extend_tree_with_wrapper(ast)
      assert_equal [range(1, 0, 1, 2), range(1, 12, 1, 14)], Maccro::Rule.find_placeholder_code_ranges(ast, 'e1')
    end
  end

  sub_test_case 'match' do
    test 'to top node' do
      ast = proc_to_ast(MethodExamples.instance_method(:m0)).children[2]
      extend_tree_with_wrapper(ast)
      m = RULE1.match(ast)

      assert_not_nil m
      assert_equal 1, m.matches.size

      assert_equal '1 || x', m.matches.first.range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches.first.placeholders.size
      assert_equal ['v1'], m.matches.first.placeholders.keys
      assert_equal 'x', m.matches.first.placeholders['v1'].source(EXAMPLE_PATH)
    end

    test 'to sub nodes on just same values' do
      ast = proc_to_ast(MethodExamples.instance_method(:m1)).children[2]
      extend_tree_with_wrapper(ast)
      m = RULE1.match(ast)

      assert_not_nil m
      assert_equal 2, m.matches.size

      assert_equal '1 || x', m.matches[0].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[0].placeholders.size
      assert_equal ['v1'], m.matches[0].placeholders.keys
      assert_equal 'x', m.matches[0].placeholders['v1'].source(EXAMPLE_PATH)

      assert_equal '1 || x', m.matches[1].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[1].placeholders.size
      assert_equal ['v1'], m.matches[1].placeholders.keys
      assert_equal 'x', m.matches[1].placeholders['v1'].source(EXAMPLE_PATH)
    end

    test 'to sub nodes on different values' do
      ast = proc_to_ast(MethodExamples.instance_method(:m2)).children[2]
      extend_tree_with_wrapper(ast)
      m = RULE1.match(ast)

      assert_not_nil m
      assert_equal 2, m.matches.size

      assert_equal '1 || x', m.matches[0].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[0].placeholders.size
      assert_equal ['v1'], m.matches[0].placeholders.keys
      assert_equal 'x', m.matches[0].placeholders['v1'].source(EXAMPLE_PATH)

      assert_equal '1 || [y]', m.matches[1].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[1].placeholders.size
      assert_equal ['v1'], m.matches[1].placeholders.keys
      assert_equal '[y]', m.matches[1].placeholders['v1'].source(EXAMPLE_PATH)
    end

    test 'to sub nodes on different expressions, only for values' do
      ast = proc_to_ast(MethodExamples.instance_method(:m3)).children[2]
      extend_tree_with_wrapper(ast)
      m = RULE1.match(ast)

      assert_not_nil m
      assert_equal 2, m.matches.size

      assert_equal '1 || x', m.matches[0].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[0].placeholders.size
      assert_equal ['v1'], m.matches[0].placeholders.keys
      assert_equal 'x', m.matches[0].placeholders['v1'].source(EXAMPLE_PATH)
      assert_equal '1 || y', m.matches[1].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[1].placeholders.size
      assert_equal ['v1'], m.matches[1].placeholders.keys
      assert_equal 'y', m.matches[1].placeholders['v1'].source(EXAMPLE_PATH)
    end

    test 'to sub nodes on different expressions, for expressions' do
      ast = proc_to_ast(MethodExamples.instance_method(:m3)).children[2]
      extend_tree_with_wrapper(ast)
      m = RULE2.match(ast)

      assert_not_nil m
      assert_equal 3, m.matches.size

      assert_equal '1 || x', m.matches[0].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[0].placeholders.size
      assert_equal ['e1'], m.matches[0].placeholders.keys
      assert_equal 'x', m.matches[0].placeholders['e1'].source(EXAMPLE_PATH)

      assert_equal '1 || foo(x)', m.matches[1].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[1].placeholders.size
      assert_equal ['e1'], m.matches[1].placeholders.keys
      assert_equal 'foo(x)', m.matches[1].placeholders['e1'].source(EXAMPLE_PATH)

      assert_equal '1 || y', m.matches[2].range.source(EXAMPLE_PATH)
      assert_equal 1, m.matches[2].placeholders.size
      assert_equal ['e1'], m.matches[2].placeholders.keys
      assert_equal 'y', m.matches[2].placeholders['e1'].source(EXAMPLE_PATH)
    end

    test 'to nodes with many placeholders' do
      ast = proc_to_ast(MethodExamples.instance_method(:m4)).children[2]
      extend_tree_with_wrapper(ast)
      m = RULE3.match(ast)

      assert_not_nil m
      assert_equal 2, m.matches.size

      assert_equal '1 < 2 < 3 < 4', m.matches[0].range.source(EXAMPLE_PATH)
      assert_equal ['e1', 'e2', 'e3', 'e4'], m.matches[0].placeholders.keys
      assert_equal '1', m.matches[0].placeholders['e1'].source(EXAMPLE_PATH)
      assert_equal '2', m.matches[0].placeholders['e2'].source(EXAMPLE_PATH)
      assert_equal '3', m.matches[0].placeholders['e3'].source(EXAMPLE_PATH)
      assert_equal '4', m.matches[0].placeholders['e4'].source(EXAMPLE_PATH)

      assert_equal '2 < 3 < 4 < 5', m.matches[1].range.source(EXAMPLE_PATH)
      assert_equal ['e1', 'e2', 'e3', 'e4'], m.matches[1].placeholders.keys
      assert_equal '2', m.matches[1].placeholders['e1'].source(EXAMPLE_PATH)
      assert_equal '3', m.matches[1].placeholders['e2'].source(EXAMPLE_PATH)
      assert_equal '4', m.matches[1].placeholders['e3'].source(EXAMPLE_PATH)
      assert_equal '5', m.matches[1].placeholders['e4'].source(EXAMPLE_PATH)
    end
  end

  sub_test_case 'after_code' do
    test 'very simple replace for values' do
      assert_equal '2 || xxx', RULE1.after_code({'v1' => 'xxx'})
      assert_equal '2 || 1024', RULE1.after_code({'v1' => '1024'})
      assert_equal '2 || :sym', RULE1.after_code({'v1' => ':sym'})
      assert_equal '2 || [xxx]', RULE1.after_code({'v1' => '[xxx]'})
    end

    test 'very simple replace for expressions' do
      assert_equal '2 || foo()', RULE2.after_code({'e1' => 'foo()'})
    end

    test 'replacements which has same placeholder twice' do
      assert_equal '1 < 2 && 2 < 3 && 3 < 4', RULE3.after_code({'e1' => '1', 'e2' => '2', 'e3' => '3', 'e4' => '4'})
    end
  end
end

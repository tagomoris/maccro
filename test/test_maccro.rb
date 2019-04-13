require_relative "helper"
require "maccro"

class MaccroTestCase < ::Test::Unit::TestCase
  suppress_warning do
    require_relative "examples/myclass"
  end

  test 'apply macro rules' do
    Maccro.register(:test_double_less_than_v, 'v1 < v2 < v3', 'v1 < v2 && v2 < v3')
    Maccro.register(:test_double_less_than_or_equal_to_e, 'e1 <= e2 <= e3', 'e1 <= e2 && e2 <= e3')
    Maccro.apply(MaccroTestCase::MyClass, MaccroTestCase::MyClass.instance_method(:method_to_test_apply))

    assert_equal "a", MaccroTestCase::MyClass.new.method_to_test_apply(1.55)
  end

  test 'applied macro does not break stack trace' do
    Maccro.register(:test_double_greater_than_v, 'v1 > v2 > v3', 'v1 > v2 && v2 > v3')
    Maccro.apply(MaccroTestCase::MyClass, MaccroTestCase::MyClass.instance_method(:method_to_test_stack_trace))

    e = nil
    begin
      MaccroTestCase::MyClass.new.method_to_test_stack_trace(1.5)
      assert false # never reaches here
    rescue => ex
      e = ex
    end

    assert_equal "14:39", e.message
    assert_match(/myclass.rb:14:in `method_to_test_stack_trace'\z/, e.backtrace.first)
  end

  test 'apply macro rules on singleton methods' do
    Maccro.register(:test_double_less_than_v, 'v1 < v2 < v3', 'v1 < v2 && v2 < v3')
    Maccro.register(:test_double_less_than_or_equal_to_e, 'e1 <= e2 <= e3', 'e1 <= e2 && e2 <= e3')
    Maccro.apply(MaccroTestCase::MyClass, MaccroTestCase::MyClass.singleton_method(:method_to_test_singleton))

    assert_equal "yay", MaccroTestCase::MyClass.method_to_test_singleton(150)
  end

  test 'apply macro rules with under option, fully qualified' do
    Maccro.register(:test_power_2_to_power_4_under_log10, 'v1 ** 2', 'v1 ** 4', under: 'Math.log10($TARGET)')
    Maccro.apply(MaccroTestCase::MyClass, MaccroTestCase::MyClass.instance_method(:method_to_test_under_fully_qualified))

    assert_equal [10**2, Math.log10(10**4)], MaccroTestCase::MyClass.new.method_to_test_under_fully_qualified(10)
  end

  test 'apply macro rules with under option, with pattern' do
    Maccro.register(:test_power_2_to_power_4_under_log10, 'v1 ** 2', 'v1 ** 4', under: 'e1.log10($TARGET)')
    Maccro.apply(MaccroTestCase::MyClass, MaccroTestCase::MyClass.instance_method(:method_to_test_under_with_pattern))

    assert_equal [10**2, Math.log10(10**4)], MaccroTestCase::MyClass.new.method_to_test_under_fully_qualified(10)
  end
end

require_relative "helper"
require "maccro"

class MaccroTestCase < ::Test::Unit::TestCase
  suppress_warning do
    require_relative "myclass"
  end

  test 'apply macro definitions' do
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
    assert_match /myclass.rb:14:in `method_to_test_stack_trace'\z/, e.backtrace.first
  end
end

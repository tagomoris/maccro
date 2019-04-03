class MaccroTestCase::MyClass
  def method_to_test_apply(v)
    if 1 < v < 2
      if 1.5 <= v <= (16 / 10.0)
        "a"
      else
        "b"
      end
    else
      "c"
    end
  end

  def method_to_test_stack_trace(x); raise "14:39" if 2 > x > 1; "a"; end
end

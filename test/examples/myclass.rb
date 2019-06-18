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

  def self.method_to_test_singleton(i)
    if 100 < i < 200
      "yay"
    else
      "boo"
    end
  end

  def method_to_test_under_fully_qualified(v)
    [
      v ** 2,
      Math.log10(v ** 2),
    ]
  end

  def method_to_test_under_with_pattern(v)
    [
      v ** 2,
      Kernel.const_get("Math").log10(v ** 2),
    ]
  end

  def self.block_to_test_rewrite_1
    ->(a, b, c){ a > b > c }
  end
end

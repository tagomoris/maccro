class MethodExamples
  def m0(x)
    1 || x
  end

  def m1(x)
    if 1 || x
      "yay"
    else
      foo(1 || x)
    end
  end

  def m2(x, y)
    if 1 || x
      "yay"
    else
      foo(1 || [y])
    end
  end

  def m3(x, y)
    if 1 || x
      "yay"
    elsif 1 || foo(x)
      "boo"
    else
      foo(1 || y)
    end
  end

  def m4
    if 1 < 2 < 3 < 4
      "yay"
    elsif 2 < 3 < 4 < 5
      "foo"
    else
      "boo"
    end
  end
end

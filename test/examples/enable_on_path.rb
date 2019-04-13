require "maccro/builtin"

Maccro::Builtin.register_all
Maccro.enable(path: __FILE__, rules: [:less_than_2, :less_than_or_equal_to_2])

module EnableOnPath1
  def self.foo
    if 1 <= 2 <= 3
      "yay"
    else
      ""
    end
  end
end

module EnableOnPath2
  def self.foo
    if 1 < 2 < 3
      "yay"
    else
      ""
    end
  end
end

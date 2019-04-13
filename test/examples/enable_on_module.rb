require "maccro/builtin"

module EnableOnModule; end

Maccro::Builtin.register_all
Maccro.enable(target: EnableOnModule, rules: [:less_than_2, :less_than_or_equal_to_2])

module EnableOnModule
  def self.foo
    if 1 < 2 < 3
      "yay"
    else
      ""
    end
  end
end

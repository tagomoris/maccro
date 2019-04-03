require "maccro"

module Maccro
  module Builtin
    RULES = {
      # [before, after (, options)]
      # options:
      #  * under
      #  * safe_reference

      # continuing less/greater-than or equal-to
      less_than_2: ['e1 < e2 < e3', '(e1 < e2 && e2 < e3)'],
      less_than_or_equal_to_2: ['e1 <= e2 <= e3', '(e1 <= e2 && e2 <= e3)'],
      greater_than_2: ['e1 > e2 > e3', '(e1 > e2 && e2 > e3)'],
      greater_than_or_equal_to_2: ['e1 >= e2 >= e3', '(e1 >= e2 && e2 >= e3)'],

      less_than_3: ['e1 < e2 < e3 < e4', '(e1 < e2 && e2 < e3 && e3 < e4)'],
      less_than_or_equal_to_3: ['e1 <= e2 <= e3 <= e4', '(e1 <= e2 && e2 <= e3 && e3 <= e4)'],
      greater_than_3: ['e1 > e2 > e3 > e4', '(e1 > e2 && e2 > e3 && e3 > e4)'],
      greater_than_or_equal_to_3: ['e1 >= e2 >= e3 >= e4', '(e1 >= e2 && e2 >= e3 && e3 >= e4)'],

      less_than_4: ['e1 < e2 < e3 < e4 < e5', '(e1 < e2 && e2 < e3 && e3 < e4 && e4 < e5)'],
      less_than_or_equal_to_4: ['e1 <= e2 <= e3 <= e4 <= e5', '(e1 <= e2 && e2 <= e3 && e3 <= e4 && e4 <= e5)'],
      greater_than_4: ['e1 > e2 > e3 > e4 > e5', '(e1 > e2 && e2 > e3 && e3 > e4 && e4 > e5)'],
      greater_than_or_equal_to_4: ['e1 >= e2 >= e3 >= e4', '(e1 >= e2 && e2 >= e3 && e3 >= e4 && e4 >= e5)'],

      # mathematic intervals
      open_interval: ['e1 < e2 < e3', '(e1 < e2 && e2 < e3)'],
      closed_interval: ['e1 <= e2 <= e3', '(e1 <= e2 && e2 <= e3)'],
      left_closed_interval: ['e1 <= e2 < e3', '(e1 <= e2 && e2 < e3)'],
      right_closed_interval: ['e1 < e2 <= e3', '(e1 < e2 && e2 <= e3)'],
    }.freeze

    RULE_GROUPS = {
      inequality_operators: [
        :less_than_2, :less_than_or_equal_to_2, :greater_than_2, :greater_than_or_equal_to_2,
        :less_than_3, :less_than_or_equal_to_3, :greater_than_3, :greater_than_or_equal_to_3,
        :less_than_4, :less_than_or_equal_to_4, :greater_than_4, :greater_than_or_equal_to_4,
      ],
      inequality_operators_2: [:less_than_2, :less_than_or_equal_to_2, :greater_than_2, :greater_than_or_equal_to_2],
      inequality_operators_3: [:less_than_3, :less_than_or_equal_to_3, :greater_than_3, :greater_than_or_equal_to_3],
      inequality_operators_4: [:less_than_4, :less_than_or_equal_to_4, :greater_than_4, :greater_than_or_equal_to_4],

      mathematic_intervals: [:open_interval, :closed_interval, :left_closed_interval, :right_closed_interval],
    }.freeze

    def self.register(name)
      if RULES.has_key?(name)
        before, after, options = RULES[name]
        options ||= {}
        Maccro.register(name, before, after, under: options.fetch(:under, nil), safe_reference: options.fetch(:safe_reference, false))
      elsif RULE_GROUPS.has_key?(name)
        RULE_GROUPS[name].each do |rule_name|
          register(rule_name)
        end
      end
    end

    def self.register_all
      RULES.each_key do |name|
        register(name)
      end
    end
  end
end

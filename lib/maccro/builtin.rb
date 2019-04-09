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

      # ActiveRecord utilities
      ar_where_in_range_exclusive: ['e1 <= v1 < e2', '{v1 => [(e1)...(e2)]}', {under: 'e1.where($TARGET)'}],
      ar_where_in_range_inclusive: ['e1 <= v1 <= e2', '{v1 => [(e1)..(e2)]}', {under: 'e1.where($TARGET)'}],
      ar_where_equal_to: ['v1 == e1', '{v1 => e1}', {under: 'e1.where($TARGET)'}],
      ar_where_not_equal_to: ['v1 != e1', '["#{v1} != ?", e1]', {under: 'e1.where($TARGET)'}],
      ar_where_larger_than: ['v1 > e1', '["#{v1} > ?", e1]', {under: 'e1.where($TARGET)'}],
      ar_where_larger_than_or_equal_to: ['v1 >= e1', '["#{v1} >= ?", e1]', {under: 'e1.where($TARGET)'}],
      ar_where_less_than: ['v1 < e1', '["#{v1} < ?", e1]', {under: 'e1.where($TARGET)'}],
      ar_where_less_than_or_equal_to: ['v1 <= e1', '["#{v1} <= ?", e1]', {under: 'e1.where($TARGET)'}],
      # TODO: and-or mixed query
      ar_and_chain_5: ['e1.where((e2 && e3 and e4 and e5 and e6 and e7))', 'e1.where(e2).where(e3).where(e4).where(e5).where(e6).where(e7)'],
      ar_and_chain_4: ['e1.where((e2 and e3 and e4 and e5 and e6))', 'e1.where(e2).where(e3).where(e4).where(e5).where(e6)'],
      ar_and_chain_3: ['e1.where((e2 and e3 and e4 and e5))', 'e1.where(e2).where(e3).where(e4).where(e5)'],
      ar_and_chain_2: ['e1.where((e2 and e3 and e4))', 'e1.where(e2).where(e3).where(e4)'],
      ar_and_chain_1: ['e1.where((e2 and e3))', 'e1.where(e2).where(e3)'],
      ar_or_chain_5: ['e1.where((e2 or e3 or e4 or e5 or e6 or e7))', 'e1.where(e2).or(e1.where(e3)).or(e1.where(e4)).or(e1.where(e5)).or(e1.where(e6)).or(e1.where(e7))'],
      ar_or_chain_4: ['e1.where((e2 or e3 or e4 or e5 or e6))', 'e1.where(e2).or(e1.where(e3)).or(e1.where(e4)).or(e1.where(e5)).or(e1.where(e6))'],
      ar_or_chain_3: ['e1.where((e2 or e3 or e4 or e5))', 'e1.where(e2).or(e1.where(e3)).or(e1.where(e4)).or(e1.where(e5))'],
      ar_or_chain_2: ['e1.where((e2 or e3 or e4))', 'e1.where(e2).or(e1.where(e3)).or(e1.where(e4))'],
      ar_or_chain_1: ['e1.where((e2 or e3))', 'e1.where(e2).or(e1.where(e3))'],
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

      activerecord_utilities: [
        :ar_where_in_range_exclusive, :ar_where_in_range_inclusive,
        :ar_where_equal_to, :ar_where_not_equal_to,
        :ar_where_larger_than, :ar_where_larger_than_or_equal_to, :ar_where_less_than, :ar_where_less_than_or_equal_to,
        :ar_and_chain_5, :ar_and_chain_4, :ar_and_chain_3, :ar_and_chain_2, :ar_and_chain_1,
        :ar_or_chain_5, :ar_or_chain_4, :ar_or_chain_3, :ar_or_chain_2, :ar_or_chain_1,
      ]
    }.freeze

    def self.rule(name)
      return nil unless RULES.has_key?(name)
      before, after, options = RULES.fetch(name)
      options ||= {}
      Rule.new(name, before, after, under: options.fetch(:under, nil), safe_reference: options.fetch(:safe_reference, false))
    end

    def self.rules(*names)
      rules = {}
      names.each do |name|
        if RULES.has_key?(name)
          rules[name] = rule(name)
        elsif RULE_GROUPS.has_key?(name)
          RULE_GROUPS[name].each do |n|
            rules[n] = rule(n)
          end
        end
      end
      rules
    end

    def self.register(name)
      if RULES.has_key?(name)
        before, after, options = RULES.fetch(name)
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

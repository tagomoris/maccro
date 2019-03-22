require_relative 'dsl'

module Maccro
  class MatchedRule
    def initialize(pairs) # TODO: + positions
      @pairs = pairs
    end
  end

  class Rule
    def initialize(name, before, after, under: nil, safe_reference_mode: false)
      @name = name
      @before = before
      @after = after
      @under = under
      @safe_reference_mode = safe_reference_mode

      @matcher = DSL.matcher(before)
    end

    def match(ast)
      nil # TODO: or MatchedRule
    end

    def rewrite(source, matched_rule)
      source # TODO: rewrite
    end
  end
end

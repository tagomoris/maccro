require_relative 'dsl'
require_relative 'matched'

module Maccro
  class Rule
    attr_reader :before, :after

    def initialize(name, before, after, under: nil, safe_reference: false)
      @name = name
      @before = before
      @after = after
      @under = under
      @safe_reference = safe_reference

      # TODO: check all placeholder in @after exist in @before
      # (placeholders in @before are not required to exist in @after, because it may be removed)

      @matcher = DSL.matcher(before)
    end

    def match(ast)
      # TODO: implement @under
      matches = []
      dig_match(matches, ast)
      if matches.empty?
        nil
      else
        Matched.new(matches)
      end
    end

    def dig_match(matches, ast)
      if @matcher.match?(ast)
        placeholders = {}
        @matcher.capture(ast, placehodlers)
        matches << Match.new(rule: self, placeholders: placeholders, range: ast.to_code_range)
      elsif ast.respond_to?(:children)
        ast.children.each do |c|
          dig_match(matches, c)
        end
      elsif ast.respond_to?(:each)
        ast.each do |i|
          dig_match(matches, i)
        end
      end
    end

    def self.find_placeholder_code_range(ast, name)
      if ast.type == :VCALL && ast.children.first.to_s == name
        return ast.to_code_range
      else
        ast.children.each do |c|
          r = find_placeholder_code_range(c, name)
          return r if r
        end
        nil
      end
    end

    def after_code(replace_pairs) # name => snippet
      ast = RubyVM::AbstractSyntaxTree.parse(@after)
      code = @after.dup
      code_range_to_name = {}
      replace_pairs.each_key do |name|
        r = self.class.find_placeholder_code_range(ast, name)
        if r
          code_range_to_name[r] = name
        end
      end
      code_range_to_name.keys.sort.reverse.each do |range|
        name = code_range_to_name[range]
        snippet = replace_pairs[name]
        code[range] = snippet
      end
      code
    end
  end
end

require_relative 'dsl'
require_relative 'matched'
require_relative 'code_util'

module Maccro
  class Rule
    attr_reader :name, :before, :after, :matcher, :under, :safe_reference

    def initialize(name, before, after, under: nil, safe_reference: false)
      @name = name
      @before = before
      @after = after
      @under = under
      @safe_reference = safe_reference

      # TODO: check a placeholder exists in @before just once
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
        @matcher.capture(ast, placeholders)
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

    def self.find_placeholder_code_ranges(ast, name)
      return [] unless ast.is_a? RubyVM::AbstractSyntaxTree::Node

      if ast.type == :VCALL && ast.children.first.to_s == name
        return [CodeRange.from_node(ast)]
      end

      ranges = []
      ast.children.each do |c|
        rs = find_placeholder_code_ranges(c, name)
        ranges.concat(rs) unless rs.empty?
      end
      ranges.sort
    end

    def after_code(replace_pairs) # name => snippet
      code = @after.dup
      ast = CodeUtil.parse_to_ast(@after)
      code_range_to_name = {}
      replace_pairs.each_key do |name|
        self.class.find_placeholder_code_ranges(ast, name).each do |r|
          code_range_to_name[r] = name
        end
      end
      # reverse is not to break code position for unprocessed code ranges
      code_range_to_name.keys.sort.reverse.each do |code_range|
        name = code_range_to_name[code_range]
        snippet = replace_pairs[name]
        range = CodeUtil.code_range_to_range(@after.dup, code_range)
        code[range] = snippet
      end
      code
    end
  end
end

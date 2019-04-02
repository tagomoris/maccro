require_relative 'code_util'

module Maccro
  Match = Struct.new(:rule, :placeholders, :range, keyword_init: true)
  # placeholders: name => code_range (in method)

  class Matched
    attr_reader :matches

    def initialize(matches)
      @matches = matches.sort{|a, b| a.range <=> b.range }
    end

    def self.get_replace_pairs(entire_source, placeholders) # name => code_ranges
      replace_pairs = {}
      placeholders.each_pair do |name, code_range|
        replace_pairs[name] = CodeUtil.code_range_to_code(entire_source, code_range)
      end
      replace_pairs # name => snippets
    end

    def rewrite(source)
      # TODO: implement @safe_reference
      source = source.dup
      # move tail to head, not to break code positions of unprocessed matches
      @matches.reverse.each do |match|
        replace_pairs = self.class.get_replace_pairs(source, match.placeholders)
        range = CodeUtil.code_range_to_range(source, match.range)
        source[range] = match.rule.after_code(replace_pairs)
      end
      source
    end
  end
end

require_relative "node"

module Maccro
  module DSL
    class LocalVariable < Node
      # LVAR: local variable in method local scope (method or local arguments)
      # DVAR: dynamically defined local variable (defined&initialized in local scope)
      SUB_NODETYPE_LIST = [:LVAR, :DVAR].freeze

      def self.match?(node)
        SUB_NODETYPE_LIST.include?(node.type)
      end
    end

    class GlobalVariable < Node
      def type; :GVAR; end
      def self.match?(node); node.type == :GVAR; end
    end

    class InstanceVariable < Node
      def type; :IVAR; end
      def self.match?(node); node.type == :IVAR; end
    end

    class ClassVariable < Node
      def type; :CVAR; end
      def self.match?(node); node.type == :CVAR; end
    end
    
    class Variable < Node
      SUB_TYPES = [LocalVariable, GlobalVariable, InstanceVariable, ClassVariable].freeze

      def type; :MACCRO_VARIABLE; end

      def self.match?(node)
        SUB_TYPES.any?{|s| s.match?(node) }
      end
    end        

    class NthRefVariable < Node
      # $1, $2 (regexp group capture reference)
      def type; :NTH_REF; end
      def self.match?(node); node.type == :NTH_REF; end
    end

    class BackRefVariable < Node
      # $&, $`, ...
      def type; :BACK_REF; end
      def self.match?(node); node.type == :BACK_REF; end
    end

    class SpecialVariable < Node
      SUB_TYPES = [NthRefVariable, BackRefVariable].freeze

      def type; :MACCRO_SPECIAL_VARIABLE; end

      def self.match?(node)
        SUB_TYPES.any?{|s| s.match?(node) }
      end
    end

    class Constant < Node
      def type; :CONST; end
      def self.match?(node); node.type == :CONST; end
    end

    class Literal < Node
      # integer, float, symbol, regex, ...
      def type; :LIT; end
      def self.match?(node); node.type == :LIT; end
    end

    class FString < Node
      # string literal without interpolation
      def type; :STR; end
      def self.match?(node); node.type == :STR; end
    end

    class DString < Node
      # string literal with interpolation ?
      def type; :DSTR; end
      def self.match?(node); node.type == :DSTR; end
    end

    class XString < Node
      # string from back quote: `...`
      # is it a literal?
      def type; :XSTR; end
      def self.match?(node); node.type == :XSTR; end
    end

    class DXString < Node
      # string from back quote with string interpolation: `... #{..} ...`
      # is it a literal?
      def type; :DXSTR; end
      def self.match?(node); node.type == :DXSTR; end
    end

    class String < Node
      SUB_TYPES = [FString, DString, XString, DXString].freeze

      def type; :MACCRO_STRING; end

      def self.match?(node)
        SUB_TYPES.any?{|s| s.match?(node) }
      end
    end

    class RegexpCompiledOnce < Node
      # regex with RE_OPTION_ONCE (see new_regexp() in parse.y)
      def type; :ONCE; end
      def self.match?(node); node.type == :ONCE; end
    end

    class DRegexp < Node
      # regex with string interpolation
      def type; :DREGX; end
      def self.match?(node); node.type == :DREGX; end
    end

    class DSymbol < Node
      # symbol with string interpolation
      def type; :DSYM; end
      def self.match?(node); node.type == :DSYM; end
    end

    class Self < Node
      def type; :SELF; end
      def self.match?(node); node.type == :SELF; end
    end

    class NilValue < Node
      def type; :NIL; end
      def self.match?(node); node.type == :NIL; end
    end

    class TrueValue < Node
      def type; :TRUE; end
      def self.match?(node); node.type == :TRUE; end
    end

    class FalseValue < Node
      def type; :FALSE; end
      def self.match?(node); node.type == :FALSE; end
    end

    class Lambda < Node
      def type; :LAMBDA; end
      def self.match?(node); node.type == :LAMBDA; end
    end

    class Array < Node
      # ARRAY and ZARRAY
      def type; :MACCRO_ARRAY; end
      def self.match?(node)
        node.type == :ARRAY || node.type == :ZARRAY
      end
    end

    class Hash < Node
      # HASH may be a hash literal, or keyword argument assignment `"a: 1" of f(a: 1)`
      # HASH(nd_alen == 0) is a keyword argument assignment, but no way to get it via AST::Node
      def type; :HASH; end
      def self.match?(node); node.type == :HASH; end
    end

    class Value < Node
      SUB_TYPES = [
        Variable, SpecialVariable, Constant,
        Literal, String, RegexpCompiledOnce, DRegexp, DSymbol,
        Self, NilValue, TrueValue, FalseValue, Lambda, Array, Hash,
      ].freeze

      def self.match?(node)
        SUB_TYPES.any?{|s| s.match?(node) }
      end
    end
  end
end

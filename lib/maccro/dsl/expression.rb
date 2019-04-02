require_relative "node"
require_relative "value"
require_relative "assign"

module Maccro
  module DSL
    class IfExp < Node
      def type; :IF; end
      def self.match?(node); node.type == :IF; end
    end

    class UnlessExp < Node
      def type; :UNLESS; end
      def self.match?(node); node.type == :UNLESS; end
    end

    class CaseExp < Node
      def type; :MACCRO_CASE; end
      def self.match?(node)
        node.type == :CASE || node.type == :CASE2
      end
    end

    # class BeginExp < Node
    #   # TODO: getting source of begin node DOES drop the beggining "begin" and tailing "end"
    #   def type; :"BEGIN"; end
    #   def self.match?(node); node.type == :"BEGIN"; end
    # end

    # class RescueExp < Node
    #   # TODO: getting source of rescue node DOES drop the beggining "begin" and tailing "end"
    #   def type; :"RESCUE"; end
    #   def self.match?(node); node.type == :"RESCUE"; end
    # end

    class AndExp < Node
      def type; :AND; end
      def self.match?(node); node.type == :AND; end
    end

    class OrExp < Node
      def type; :OR; end
      def self.match?(node); node.type == :OR; end
    end

    class CallExp < Node
      def type; :CALL; end
      def self.match?(node); node.type == :CALL; end
    end

    class OperatorCallExp < Node
      def type; :OPCALL; end
      def self.match?(node); node.type == :OPCALL; end
    end

    class SafeCallExp < Node
      # x&.foo(1)
      def type; :QCALL; end
      def self.match?(node); node.type == :QCALL; end
    end

    class FunctionCallExp < Node
      def type; :FCALL; end
      def self.match?(node); node.type == :FCALL; end
    end

    class VCallExp < Node
      # function call without arguments
      def type; :VCALL; end
      def self.match?(node); node.type == :VCALL; end
    end

    class SuperExp < Node
      # super or super without arguments
      def type; :MACCRO_SUPER; end
      def self.match?(node)
        node.type == :SUPER || node.type == :ZSUPER
      end
    end

    class YieldExp < Node
      def type; :YIELD; end
      def self.match?(node); node.type == :YIELD; end
    end

    class MatchExp < Node
      # MATCH:  /.../ without `=~` (matches to $_ implicitly)
      # MATCH2: /.../ =~ "..." (left side)
      # MATCH3: "..." =~ /.../ (right side)
      def type; :MACCRO_MATCH; end
      def self.match?(node)
        t = node.type
        t == :MATCH || t == :MATCH2 || t == :MATCH3
      end
    end

    class DefineMethod < Node
      def type; :DEFN; end
      def self.match?(node); node.type == :DEFN; end
    end

    class DefineSingletonMethod < Node
      def type; :DEFS; end
      def self.match?(node); node.type == :DEFS; end
    end

    class Colon2Exp < Node
      def type; :COLON2; end
      def self.match?(node); node.type == :COLON2; end
    end

    class Colon3Exp < Node
      # top level reference (::A)
      def type; :COLON3; end
      def self.match?(node); node.type == :COLON3; end
    end

    class Dot2Exp < Node
      # range constructor (inclusive)
      def type; :DOT2; end
      def self.match?(node); node.type == :DOT2; end
    end

    class Dot3Exp < Node
      # range constructor (exclusive)
      def type; :DOT3; end
      def self.match?(node); node.type == :DOT3; end
    end

    class Flip2Exp < Node
      # flip-flop (inclusive)
      def type; :FLIP2; end
      def self.match?(node); node.type == :FLIP2; end
    end

    class Flip3Exp < Node
      # flip-flop (exclusive)
      def type; :FLIP3; end
      def self.match?(node); node.type == :FLIP3; end
    end

    class DefinedExp < Node
      def type; :DEFINED; end
      def self.match?(node); node.type == :DEFINED; end
    end

    class Expression < Node
      SUB_TYPES = [
        Value, Assignment,
        IfExp, UnlessExp, CaseExp,
        # BeginExp, RescueExp,
        AndExp, OrExp,
        CallExp, OperatorCallExp, SafeCallExp, FunctionCallExp, VCallExp,
        SuperExp, YieldExp,
        MatchExp,
        DefineMethod, DefineSingletonMethod,
        Colon2Exp, Colon3Exp, Dot2Exp, Dot3Exp, Flip2Exp, Flip3Exp,
        DefinedExp,
      ].freeze

      def self.match?(node)
        SUB_TYPES.any?{|s| s.match?(node) }
      end
    end
  end
end

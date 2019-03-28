require_relative "node"
require_relative "value"
require_relative "assign"

module Maccro
  module DSL
    class IfExp < Node
      def type; :IF; end
    end

    class UnlessExp < Node
      def type; :UNLESS; end
    end

    class CaseExp < Node
      def match?(node)
        node.type == :CASE || node.type == :CASE2
      end
    end

    class BeginExp < Node
      def type; :"BEGIN"; end
    end

    class AndExp < Node
      def type; :AND; end
    end

    class OrExp < Node
      def type; :OR; end
    end

    class CallExp < Node
      def type; :CALL; end
    end

    class OperatorCallExp < Node
      def type; :OPCALL; end
    end

    class SafeCallExp < Node
      # x&.foo(1)
      def type; :QCALL; end
    end

    class FunctionCallExp < Node
      def type; :FCALL; end
    end

    class VCallExp < Node
      # function call without arguments
      def type; :VCALL; end
    end

    class SuperExp < Node
      # super or super without arguments
      def match?(node)
        node.type == :SUPER || node.type == :ZSUPER
      end
    end

    class YieldExp < Node
      def type; :YIELD; end
    end

    class MatchExp < Node
      # MATCH:  /.../ without `=~` (matches to $_ implicitly)
      # MATCH2: /.../ =~ "..." (left side)
      # MATCH3: "..." =~ /.../ (right side)
      def match?(node)
        t = node.type
        t == :MATCH || t == :MATCH2 || t == :MATCH3
      end
    end

    class DefineMethod < Node
      def type; DEFN; end
    end

    class DefineSingletonMethod < Node
      def type; DEFS; end
    end

    class Colon2Exp < Node
      def type; COLON2; end
    end

    class Colon3Exp < Node
      # top level reference (::A)
      def type; COLON3; end
    end

    class Dot2Exp < Node
      # range constructor (inclusive)
      def type; DOT2; end
    end

    class Dot3Exp < Node
      # range constructor (exclusive)
      def type; DOT3; end
    end

    class Flip2Exp < Node
      # flip-flop (inclusive)
      def type; FLIP2; end
    end

    class Flip3Exp < Node
      # flip-flop (exclusive)
      def type; FLIP3; end
    end

    class DefinedExp < Node
      def type; DEFINED; end
    end

    class Expression < NodeGroup
      SUB_TYPES = [
        Value, Assignment,
        IfExp, UnlessExp, CaseExp, BeginExp, BeginExp, AndExp, OrExp,
        CallExp, OperatorCallExp, SafeCallExp, FunctionCallExp, VCallExp,
        SuperExp, YieldExp,
        MatchExp,
        DefineMethod, DefineSingletonMethod,
        Colon2Exp, Colon3Exp, Dot2Exp, Dot3Exp, Flip2Exp, Flip3Exp,
        DefinedExp,
      ].freeze

      def subtypes
        SUB_TYPES
      end
    end
  end
end

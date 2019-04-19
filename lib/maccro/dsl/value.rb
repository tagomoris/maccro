require_relative "node"
require_relative "literal"

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

    class Self < Node
      def type; :SELF; end
      def self.match?(node); node.type == :SELF; end
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

require_relative "node"

module Maccro
  module DSL
    class MultiAssignment < Node
      def type; :MASGN; end
    end

    class LocalVariableAssignment < Node
      def type; :LASGN; end
    end

    class DynamicVariableAssignmentOutOfScope < Node
      # x = 1; 1.times{ x = 1 }
      def type; :DASGN; end
    end

    class DynamicVariableAssignmentCurrentScope < Node
      # 1.times{ x = 1 }
      def type; :DASGN_CUPR; end
    end

    class InstanceVariableAssignment < Node
      def type; :IASGN; end
    end

    class ClassVariableAssignment < Node
      def type; :CVASGN; end
    end

    class GlobalVariableAssignment < Node
      def type; :GASGN; end
    end

    class AttributeAssignment < Node
      # x[1] = 1
      # x.a = 1
      def type; :ATTRASGN; end
    end

    class ArrayAssignmentWithOperator < Node
      # x[1] += 1
      def type; :OP_ASGN1; end
    end

    class AttributeAssignmentWithOperator < Node
      # x.a += 1
      def type; :OP_ASGN2; end
    end

    class AndAssignment < Node
      # x &&= y
      def type; :OP_ASGN_AND; end
    end

    class OrAssignment < Node
      # x ||= y
      def type; :OP_ASGN_OR; end
    end

    class ConstantDeclaration < Node
      def type; :CDECL; end
    end

    class ConstantDeclarationWithOperator < Node
      # A::B ||= 1
      # A::B += 1
      def type; :OP_CDECL; end
    end

    class Assignment < NodeGroup
      SUB_TYPES = [
        MultiAssignment, LocalVariableAssignment,
        DynamicVariableAssignmentOutOfScope, DynamicVariableAssignmentCurrentScope,
        InstanceVariableAssignment, ClassVariableAssignment, GlobalVariableAssignment,
        AttributeAssignment, ArrayAssignmentWithOperator, AttributeAssignmentWithOperator,
        AndAssignment, OrAssignment,
        ConstantDeclaration, ConstantDeclarationWithOperator,
      ].freeze

      def subtypes
        SUB_TYPES
      end
    end
  end
end

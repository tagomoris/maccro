module Maccro
  module DSL
    class Node
      def match?(node)
        node.type == type
      end
    end

    class NodeGroup
      def match?(node)
        subtypes.any?{|s| s.match?(node) }
      end
    end
  end
end

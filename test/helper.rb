require "test/unit"
$LOAD_PATH << File.join(__dir__, "..", "lib")

def parse_to_ast(code)
  v = $VERBOSE
  $VERBOSE = nil
  RubyVM::AbstractSyntaxTree.parse(code)
ensure
  $VERBOSE = v
end

def proc_to_ast(block)
  v = $VERBOSE
  $VERBOSE = nil
  RubyVM::AbstractSyntaxTree.of(block)
ensure
  $VERBOSE = v
end

def extend_tree_with_wrapper(tree)
  return unless tree.is_a?(RubyVM::AbstractSyntaxTree::Node)
  tree.extend Maccro::DSL::ASTNodeWrapper unless tree.is_a?(Maccro::DSL::ASTNodeWrapper)
  tree.children.each do |c|
    extend_tree_with_wrapper(c)
  end
end

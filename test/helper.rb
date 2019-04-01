require "test/unit"
$LOAD_PATH << File.join(__dir__, "..", "lib")

def parse_to_ast(code)
  RubyVM::AbstractSyntaxTree.parse(code)
end

def proc_to_ast(block)
  RubyVM::AbstractSyntaxTree.of(block)
end

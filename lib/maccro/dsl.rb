require_relative 'dsl/node'
require_relative 'dsl/literal'
require_relative 'dsl/value'
require_relative 'dsl/assign'
require_relative 'dsl/expression'
require_relative 'code_util'

module Maccro
  module DSL
    def self.matcher(code_snippet)
      ast = CodeUtil.parse_to_ast(code_snippet)
      # Top level node should be SCOPE, and children[2] will be the first expression node
      return ast_node_to_dsl_node(ast.children[2])
    end

    def self.ast_node_to_dsl_node(ast_node)
      unless ast_node.is_a?(RubyVM::AbstractSyntaxTree::Node)
        if ast_node.is_a?(Array)
          ast_node.times do |i|
            ast_node[i] = ast_node_to_dsl_node(ast_node[i])
          end
        end
        return ast_node
      end

      # ast_node.is_a?(RubyVM::AbstractSyntaxTree::Node)
      ast_node.extend ASTNodeWrapper
      if is_placeholder?(ast_node)
        return placeholder_to_matcher_node(ast_node)
      end

      ast_node.children.each_with_index do |n, i|
        ast_node.children[i] = ast_node_to_dsl_node(n)
      end
      ast_node
    end

    def self.is_placeholder?(node)
      if node.type == :VCALL && placeholder_name?(node.children.first)
        true
      elsif node.type == :GVAR && node.children.first == :'$TARGET'
        true
      else
        false
      end
    end

    def self.placeholder_name?(sym)
      # Expression: "eN"
      # Value: "vN"
      # String: "sN"
      # Symbol: "yN"
      # Number: "nN"
      # Regular expression: "rN"
      # N index is 1 origin
      (sym.to_s =~ /^[evsynr][1-9]\d*$/).!.!
    end

    def self.placeholder_to_matcher_node(placeholder_node)
      name = placeholder_node.children.first.to_s
      nodeClass = case name
                  when '$TARGET' then AnyNode
                  when /^s([1-9]\d*)$/ then String
                  when /^y([1-9]\d*)$/ then Symbol
                  when /^n([1-9]\d*)$/ then Number
                  when /^r([1-9]\d*)$/ then RegularExpression
                  when /^v([1-9]\d*)$/ then Value
                  when /^e([1-9]\d*)$/ then Expression
                  else
                    raise "BUG: unregistered placeholder name `#{name}`"
                  end
      nodeClass.new(name, placeholder_node.to_code_range)
    end
  end
end

###
# List of AST nodes: from node_children() in ast.c

# ASGN means Assignment

# BLOCK
# IF (expression)
# UNLESS (expression)
# CASE (expression)
# CASE2 (expression)
# WHEN
# WHILE
# UNTIL
# ITER
# FOR
# FOR_MASGN
# BREAK
# NEXT
# RETURN
# REDO
# RETRY
# BEGIN (expression)
# RESCUE
# RESBODY
# ENSURE
# AND (expression)
# OR  (expression)
# MASGN      (assign)
# LASGN      (assign)
# DASGN      (assign)
# DASGN_CUPR (assign)
# IASGN      (assign)
# CVASGN     (assign)
# GASGN      (assign)
# CDECL      (assign)
# OP_ASGN1    (assign)
# OP_ASGN2    (assign)
# OP_ASGN_AND (assign)
# OP_ASGN_OR  (assign)
# OP_CDECL    (assign)
# CALL   (expression)
# OPCALL (expression)
# QCALL  (expression)
# FCALL  (expression)
# VCALL  (expression)
# SUPER  (expression)
# ZSUPER (expression)
# ARRAY  (value)
# VALUES [return arguments]
# ZARRAY (value)
# HASH   (value)
# YIELD (expression)
# LVAR (value)
# DVAR (value)
# IVAR (value)
# CONST (value)
# CVAR (value)
# GVAR (value)
# NTH_REF (value)
# BACK_REF (value)
# MATCH  (expression)
# MATCH2 (expression)
# MATCH3 (expression)
# LIT (value)
# STR (value)
# XSTR (value)
# ONCE (value)
# DSTR (value)
# DXSTR (value)
# DREGX (value)
# DSYM (value)
# EVSTR [String interpolation (in string literals)]
# ARGSCAT
# AGSPUSH
# SPLAT
# BLOCK_PASS
# DEFN (expression)
# DEFS (expression)
# ALIAS
# VALIAS
# UNDEF
# CLASS
# MODULE
# SCLASS
# COLON2 (expression)
# COLON3 (expression)
# DOT2  (expression)
# DOT3  (expression)
# FLIP2 (expression)
# FLIP3 (expression)
# SELF  (value)
# NIL   (value)
# TRUE  (value)
# FALSE (value)
# ERRINFO
# DEFINED (expression)
# POSTEXE
# ATTRASGN (assign)
# LAMBDA (value)
# OPT_ARG
# KW_ARG
# POSTARG
# ARGS
# SCOPE
# ARGS_AUX
# LAST

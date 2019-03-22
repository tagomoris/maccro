module Maccro
  module DSL
  end
end

require_relative 'dsl/value'
require_relative 'dsl/assign'
require_relative 'dsl/expression'

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

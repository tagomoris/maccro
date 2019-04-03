require_relative "./maccro/version"

require_relative "./maccro/dsl"
require_relative "./maccro/rule"
require_relative "./maccro/code_util"

class X
  def yay(v)
    if 1 < v < 3
      if 3 > v > 1
        puts "yay"
      else
        puts "bomb"
      end
    else
      puts "boo"
    end
    puts "done"
  end
end

module Maccro
  @@dic = {}

  def self.register(name, before, after, under: nil, safe_reference: false)
    if under
      raise NotImplementedError, "TODO: implement it"
    end
    if safe_reference
      raise NotImplementedError, "TODO: implement it"
    end      
    @@dic[name] = Rule.new(name, before, after, under: under, safe_reference: safe_reference)
  end

  def self.apply(mojule, method, verbose: false)
    if !method.source_location
      raise "Native method can't be redefined"
    end

    ast = CodeUtil.proc_to_ast(method)
    # This node should be SCOPE node (just under DEFN or DEFS)
    # But its code range is equal to code range of DEFN/DEFS
    CodeUtil.extend_tree_with_wrapper(ast)

    first_lineno = ast.first_lineno
    first_column = ast.first_column

    iseq = nil
    path = nil

    source = nil
    rewrite_method_code_range = nil

    @@dic.each_pair do |name, rule|
      if matched = rule.match(ast)
        if !source || !path
          iseq ||= CodeUtil.proc_to_iseq(method)
          if !iseq
            raise "Native methods can't be redefined"
          end
          path ||= iseq.absolute_path
          if !path # STDIN or -e
            raise "Methods from stdin or -e can't be redefined"
          end
          source ||= File.read(path)
        end

        source = matched.rewrite(source)

        ast = CodeUtil.get_method_node(CodeUtil.parse_to_ast(source), method.name, first_lineno, first_column)
        CodeUtil.extend_tree_with_wrapper(ast)
        rewrite_method_code_range = CodeRange.from_node(ast)
      end
    end

    if source && path && rewrite_method_code_range
      eval_source = (" " * first_column) + rewrite_method_code_range.get(source) # restore the original indentation
      puts eval_source if verbose
      mojule.module_eval(eval_source, path, first_lineno)
    end
  end
end

Maccro.register(:double_less_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3')
Maccro.register(:double_greater_than, 'e1 > e2 > e3', 'e1 > e2 && e2 > e3')
# Maccro.register(:double_greater_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3', safe_reference: true)
# Maccro.register(:activerecord_where_equal, 'v1 = v2', 'v1 => v2', under: 'e.where($TARGET)')

Maccro.apply(X, X.instance_method(:yay), verbose: true)

X.new.yay(2)

require_relative "./maccro/version"

require_relative "./maccro/dsl"
require_relative "./maccro/rule"
require_relative "./maccro/code_util"

class X
  def yay(v)
    if 1 < v < 3
      puts "yay"
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

  def self.apply(mojule, method)
    if !method.source_location
      raise "Native method can't be redefined"
    end

    ast = CodeUtil.proc_to_ast(method)
    # This node should be SCOPE node (just under DEFN or DEFS)
    # But its code range is equal to code range of DEFN/DEFS
    CodeUtil.extend_tree_with_wrapper(ast)

    @@dic.each_pair do |name, rule|
      if matched = rule.match(ast)
        mojule = method.owner
        iseq = CodeUtil.proc_to_iseq(method)
        path = iseq.absolute_path
        if !path # STDIN or -e
          raise "Methods not in files can't be redefined"
        end

        source = matched.rewrite(File.read(path))
        updated_method_node = CodeUtil.get_method_node(CodeUtil.parse_to_ast(source), method.name, ast.first_lineno, ast.first_column)
        updated_method_code_range = CodeRange.from_node(updated_method_node)
        updated_method_source = updated_method_code_range.get(source)

        eval_source = (" " * (updated_method_node.first_column)) + updated_method_source # for same indentation
        puts eval_source
        # TODO: consider $VERBOSE ?
        mojule.module_eval(eval_source, path, updated_method_node.first_lineno)
        return # TODO: currently, just one rule can rewrite a method
      end
    end
  end
end

Maccro.register(:double_greater_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3')
# Maccro.register(:double_greater_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3', safe_reference: true)
# Maccro.register(:activerecord_where_equal, 'v1 = v2', 'v1 => v2', under: 'e.where($TARGET)')

Maccro.apply(X, X.instance_method(:yay))

X.new.yay(2)

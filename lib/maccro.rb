require_relative "./maccro/version"

require_relative "./maccro/dsl"
require_relative "./maccro/rule"

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

  def self.register(name, before, after, under: nil, safe_reference_mode: false)
    if under
      raise NotImplementedError, "TODO: implement it"
    end
    if safe_reference_mode
      raise NotImplementedError, "TODO: implement it"
    end      
    @@dic[name] = Rule.new(name, before, after, under: under, safe_reference_mode: safe_reference_mode)
  end

  def self.apply(mojule, method)
    if !method.source_location
      raise "Native method can't be redefined"
    end

    mojule = method.owner
    ast = RubyVM::AbstractSyntaxTree.of(method)
    iseq = RubyVM::InstructionSequence.of(method)
    path = iseq.absolute_path
    if path == '-e' # TODO: OR STDIN
      raise "Methods not in files can't be redefined"
    end

    method_range = CodeRange.from_node(path, ast)
    source = method_range.source
    changed = false

    @@dic.each_pair do |name, rule|
      if matched = rule.match(ast)
        source = rule.rewrite(source, matched)
        changed = true
      end
    end

    if changed
      eval_source = (" " * (method_range.first_column)) + source # for same indentation
      mojule.module_eval(source, path, method_range.first_lineno)
    end
  end
end

Maccro.register(:double_greater_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3')
# Maccro.register(:activerecord_where_equal, 'v1 = v2', 'v1 => v2', under: 'e.where($TARGET)')

Maccro.apply(X, X.method(:yay))

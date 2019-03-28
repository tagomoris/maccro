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

    ast = RubyVM::AbstractSyntaxTree.of(method)

    @@dic.each_pair do |name, rule|
      if matched = rule.match(ast)
        pp(here: "matched")
        mojule = method.owner
        iseq = RubyVM::InstructionSequence.of(method)
        path = iseq.absolute_path
        if !path # STDIN or -e
          raise "Methods not in files can't be redefined"
        end

        method_range = ast.to_code_range
        source = matched.rewrite(method_range.source(path))

        eval_source = (" " * (method_range.first_column)) + source # for same indentation
        pp(here: "going to eval", path: path, lineno: method_range.first_lineno)
        puts eval_source
        # mojule.module_eval(eval_source, path, method_range.first_lineno)
        return # TODO: currently, just one rule can rewrite a method
      end
    end
  end
end

Maccro.register(:double_greater_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3')
# Maccro.register(:activerecord_where_equal, 'v1 = v2', 'v1 => v2', under: 'e.where($TARGET)')

Maccro.apply(X, X.instance_method(:yay))

X.new.yay(2)

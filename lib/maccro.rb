require_relative "./maccro/version"

require_relative "./maccro/dsl"
require_relative "./maccro/rule"
require_relative "./maccro/code_util"

require_relative "./maccro/kernel_ext"

module Maccro
  @@dic = {}
  @@trace_global = nil

  def self.register(name, before, after, under: nil, safe_reference: false)
    # Maccro.register(:double_less_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3')
    # Maccro.register(:double_greater_than, 'e1 > e2 > e3', 'e1 > e2 && e2 > e3')
    # Maccro.register(:double_greater_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3', safe_reference: true)
    # Maccro.register(:activerecord_where_equal, 'v1 = v2', 'v1 => v2', under: 'e.where($TARGET)')
    if safe_reference
      raise NotImplementedError, "TODO: implement it"
    end      
    @@dic[name] = Rule.new(name, before, after, under: under, safe_reference: safe_reference)
  end

  def self.clear!
    @@dic = {}
  end

  def self.execute(block=nil, rules: @@dic, verbose: false, get_code: false, &block_param)
    block = block_param if !block && block_param
    if block.arity > 0
      raise "Block with parameters can't be executed via Maccro"
    end

    rewrite(block, rules: rules, verbose: verbose, get_code: get_code).call
  end

  # Maccro.rewrite(->(){ ... }).call(args)
  def self.rewrite(block=nil, rules: @@dic, verbose: false, get_code: false, &block_param)
    block = block_param if !block && block_param
    if !block.source_location
      raise "Native block can't be rewritten"
    end

    ast = CodeUtil.proc_to_ast(block)
    if !ast
      raise "Failed to load AST nodes - source file may be invisible"
    end
    CodeUtil.extend_tree_with_wrapper(ast)

    first_lineno = ast.first_lineno
    first_column = ast.first_column

    source, _ = CodeUtil.get_source_path(block)

    rewrite_happens = false
    first_time = true

    while rewrite_happens || first_time
      rewrite_happens = false
      first_time = false

      try_once = ->(rule) {
        matched = rule.match(ast)
        next unless matched

        source = matched.rewrite(source)
        ast = CodeUtil.get_proc_node(CodeUtil.parse_to_ast(source), first_lineno, first_column)
        CodeUtil.extend_tree_with_wrapper(ast)
        rewrite_happens = true
        try_once.call(rule)
      }

      rules.each_pair do |_name, this_rule|
        try_once.call(this_rule)
        break if rewrite_happens # to retry all rules
      end
    end

    eval_source = if ast.type == :SCOPE
                    CodeUtil.convert_scope_to_lambda(CodeRange.from_node(ast).get(source))
                  else
                    CodeRange.from_node(ast).get(source)
                  end
    return eval_source if get_code
    puts eval_source if verbose
    block.binding.eval(eval_source)
  end

  # Maccro.apply(X, X.instance_method(:yay), verbose: true)
  def self.apply(mojule, method, rules: @@dic, verbose: false, from_trace: false, get_code: false)
    if !method.source_location
      raise "Native method can't be redefined"
    end

    ast = CodeUtil.proc_to_ast(method)
    if !ast
      if from_trace
        # unknown and unexpected loaded ruby code (which many not have visible source)
        return
      else
        raise "Failed to load AST nodes - source file may be invisible: #{method}"
      end
    end
    # This node should be SCOPE node (just under DEFN or DEFS)
    # But its code range is equal to code range of DEFN/DEFS
    CodeUtil.extend_tree_with_wrapper(ast)

    is_singleton_method = (mojule != method.owner)

    first_lineno = ast.first_lineno
    first_column = ast.first_column

    source, path = CodeUtil.get_source_path(method)
    # The reason to get the entire source code is to capture/rewrite
    # the exact code snippet using CodeRange (positions in the entire file)

    rewrite_method_code_range = nil

    rewrite_happens = false
    first_time = true

    while rewrite_happens || first_time
      rewrite_happens = false
      first_time = false

      try_once = ->(rule) {
        matched = rule.match(ast)
        next unless matched

        source = matched.rewrite(source)
        ast = CodeUtil.get_method_node(CodeUtil.parse_to_ast(source), method.name, first_lineno, first_column, singleton_method: is_singleton_method)
        CodeUtil.extend_tree_with_wrapper(ast)
        rewrite_happens = true
        try_once.call(rule)
      }

      rules.each_pair do |_name, this_rule|
        try_once.call(this_rule)
        break if rewrite_happens # to retry all rules
      end
    end

    rewrite_method_code_range = CodeRange.from_node(ast)
    if source && path && rewrite_method_code_range
      eval_source = (" " * first_column) + rewrite_method_code_range.get(source) # restore the original indentation
      return eval_source if get_code
      puts eval_source if verbose
      CodeUtil.suppress_warning do
        mojule.module_eval(eval_source, path, first_lineno)
      end
    end
  end

  # TODO: check visibility: private method is still private method even after module_eval?

  def self.enable(target: nil, path: nil, rules: nil)
    if target || path
      enable_trace(target: target, path: path, rule_names: rules)
    else
      if rules
        raise "Cannot enable globally with specific rules"
      end
      enable_trace(globally: true)
    end
  end

  def self.enable_trace(target: nil, path: nil, globally: false, rule_names: nil)
    if globally && @@trace_global
      return nil
    end

    if rule_names
      rules = rule_names.map{|n| [n, @@dic[n]] }.to_h
    else
      rules = @@dic
    end

    trace = TracePoint.new(:end) do |tp|
      current_location = tp.path
      next unless globally || target == tp.self || path == current_location

      this = tp.self

      methods = (
        this.instance_methods(false).map{|m| this.instance_method(m) } +
        this.private_instance_methods(false).map{|m| this.instance_method(m) } +

        # NameError: undefined singleton method `provides?' for `Bundler::RubygemsIntegration::Legacy'
        this.singleton_methods.map{|m| this.singleton_method(m) rescue nil }.compact
      )

      methods.each do |method|
        source_location = method.source_location
        next if !source_location # native method
        next if source_location.first == '-e'
        next if source_location.first != current_location # methods defined in other file
        Maccro.apply(this, method, rules: rules, from_trace: true)
      end
    end

    if globally
      @@trace_global = trace
    end
    trace.enable
    nil
  end
end

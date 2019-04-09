require_relative "./maccro/version"

require_relative "./maccro/dsl"
require_relative "./maccro/rule"
require_relative "./maccro/code_util"

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

  def self.apply(mojule, method, verbose: false, from_trace: false)
    # Maccro.apply(X, X.instance_method(:yay), verbose: true)
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

        ast = CodeUtil.get_method_node(CodeUtil.parse_to_ast(source), method.name, first_lineno, first_column, singleton_method: is_singleton_method)
        CodeUtil.extend_tree_with_wrapper(ast)
        rewrite_method_code_range = CodeRange.from_node(ast)
      end
    end

    if source && path && rewrite_method_code_range
      eval_source = (" " * first_column) + rewrite_method_code_range.get(source) # restore the original indentation
      puts eval_source if verbose
      CodeUtil.suppress_warning do
        mojule.module_eval(eval_source, path, first_lineno)
      end
    end
  end

  # TODO: check visibility: private method is still private method even after module_eval?

  # TODO: add a feature to enable single rule in a specified path (or a module)

  def self.enable(target: nil)
    if target
      enable_trace(target: target)
    else
      enable_trace(globally: true)
    end
  end

  def self.enable_trace(target: nil, globally: false)
    if globally && @@trace_global
      return nil
    end

    trace = TracePoint.new(:end) do |tp|
      next unless globally || target == tp.self

      current_location = tp.path
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
        next if source_location.first == '-e' || source_location.first != current_location
        Maccro.apply(this, method, from_trace: true)
      end
    end

    if globally
      @@trace_global = trace
    end
    trace.enable
    nil
  end
end

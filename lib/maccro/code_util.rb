module Maccro
  module CodeUtil
    def self.code_position_to_index(source, lineno, column)
      source_lines = source.lines # including newline at the end of line
      if source_lines.size < lineno
        raise "too few lines for specified position: lineno:#{lineno}, column:#{column}"
      end
      counter = 1
      index = 0
      while counter < lineno
        index += source_lines.shift.size
        counter += 1
      end
      if source_lines.empty?
        raise "too few lines for specified position: lineno:#{lineno}, column:#{column}"
      end
      # column is 0 origin
      if source_lines.first.size < 1
        raise "empty line at the end of source"
      end
      if source_lines.first.size < column
        raise "too few chars in the line for specified position: lineno:#{lineno}, column:#{column}"
      end
      return index + column
    end

    def self.code_range_to_range(source, code_range)
      begin_index = code_position_to_index(source, code_range.first_lineno, code_range.first_column)
      end_index = code_position_to_index(source, code_range.last_lineno, code_range.last_column)
      Range.new(begin_index, end_index, true) # exclude end char
    end

    def self.code_range_to_code(source, code_range)
      source[code_range_to_range(source, code_range)]
    end

    def self.suppress_warning
      v = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = v
    end

    def self.parse_to_ast(code)
      suppress_warning do
        RubyVM::AbstractSyntaxTree.parse(code)
      end
    end

    def self.proc_to_ast(block)
      suppress_warning do
        RubyVM::AbstractSyntaxTree.of(block)
      end
    end

    def self.proc_to_iseq(block)
      RubyVM::InstructionSequence.of(block)
    end

    def self.extend_tree_with_wrapper(tree)
      return unless tree.is_a?(RubyVM::AbstractSyntaxTree::Node)
      tree.extend Maccro::DSL::ASTNodeWrapper unless tree.is_a?(Maccro::DSL::ASTNodeWrapper)
      tree.children.each do |c|
        extend_tree_with_wrapper(c)
      end
    end

    def self.convert_scope_to_lambda(scope_source)
      raise "Scope source must start with '{'" unless scope_source.start_with?('{')
      raise "Scope source must end with '}'" unless scope_source.end_with?('}')

      if m = scope_source.match(/^\{\s*\|(.*)\|/o)
        matched_source = m[0]
        args_source = m[1]
        return "->(#{args_source})" + scope_source.sub(matched_source, '{')
      end

      "->" + scope_source
    end

    def self.get_source_path(block)
      iseq = CodeUtil.proc_to_iseq(block)
      if !iseq
        raise "Native methods can't be redefined"
      end
      path = iseq.absolute_path
      if !path # STDIN or -e
        raise "Methods from stdin or -e can't be redefined"
      end
      source = File.read(path)

      return source, path
    end

    def self.get_proc_node(node, lineno, column)
      return nil unless node.type == :SCOPE
      dig_proc_node(node, lineno, column)
    end

    def self.dig_proc_node(node, lineno, column)
      return nil unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)
      is_target_scope = ->(n){ n.type == :SCOPE && n.first_lineno == lineno && n.first_column == column }

      case node.type
      when :LAMBDA # ->(){ }
        if is_target_scope.call(node.children[0])
          return node
        end
      when :ITER # method call with block (iterator?)
        if node.children[0].type == :FCALL \ # lambda{}, proc{}
           && (node.children[0].children[0] == :lambda || node.children[0].children[0] == :proc) \
           && is_target_scope.call(node.children[1])
          return node
        elsif node.children[0].type == :CALL \ # Kernel.lambda, Kernel.proc{}, Proc.new{}
              && node.children[0].children[0].type == :CONST \
              && (node.children[0].children[0].children[0] == :Kernel && (node.children[0].children[1] == :lambda || node.children[0].children[1] == :proc) \
                  || node.children[0].children[0].children[0] == :Proc && node.children[0].children[1] == :new ) \
              && is_target_scope.call(node.children[1])
          return node
        end
      when :SCOPE # for block parameters
        if is_target_scope.call(node)
          return node
        end
      end

      if node.respond_to?(:children)
        node.children.each do |n|
          r = dig_proc_node(n, lineno, column)
          return r if r
        end
      end

      nil
    end

    def self.get_method_node(node, method_name, lineno, column, singleton_method: false)
      if singleton_method
        # TODO: consider receiver filter
        # 0: (SELF@57:6-57:10)
        dig_method_node(node, :DEFS, 1, method_name, lineno, column)
      else
        dig_method_node(node, :DEFN, 0, method_name, lineno, column)
      end
    end

    def self.dig_method_node(node, def_type, method_name_index, method_name, lineno, column)
      return nil unless node.is_a?(RubyVM::AbstractSyntaxTree::Node)
      if node.type == def_type && node.children[method_name_index] == method_name && node.first_lineno == lineno && node.first_column == column
        return node
      elsif node.respond_to?(:children)
        node.children.each do |n|
          r = dig_method_node(n, def_type, method_name_index, method_name, lineno, column)
          return r if r
        end
      end
      nil
    end
  end
end

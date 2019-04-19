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

    def self.get_source_path_iseq(method)
      iseq ||= CodeUtil.proc_to_iseq(method)
      if !iseq
        raise "Native methods can't be redefined"
      end
      path ||= iseq.absolute_path
      if !path # STDIN or -e
        raise "Methods from stdin or -e can't be redefined"
      end
      source ||= File.read(path)

      return source, path, iseq
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

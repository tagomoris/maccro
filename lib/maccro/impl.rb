module Maccro
  module Impl
    # for internal use
    def self.update_by_rules(ast, source, rules)
      CodeUtil.extend_tree_with_wrapper(ast)

      rewrite_happens = false
      first_time = true

      while rewrite_happens || first_time
        rewrite_happens = false
        first_time = false

        try_once = ->(rule) {
          matched = rule.match(ast)
          next unless matched

          source = matched.rewrite(source)
          ast = yield source, ast.first_lineno, ast.first_column
          CodeUtil.extend_tree_with_wrapper(ast)
          rewrite_happens = true
          try_once.call(rule)
        }

        rules.each_pair do |_name, this_rule|
          try_once.call(this_rule)
          break if rewrite_happens # to retry all rules
        end
      end

      return ast, source
    end
  end
end

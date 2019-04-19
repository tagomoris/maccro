# Maccro

Maccro is a library to introduce macro (dynamic code rewriting), written in Ruby 100%.

```ruby
# name, before, after
Maccro.register(:double_less_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3')

# This rewrites this code
class Foo
  def foo(v)
    if 1 < v < 2
      "hit!"
    end
  end
end

Maccro.apply(Foo, Foo.instance_method(:foo))

# To this (valid Ruby) code dynamically
class Foo
  def foo(v)
    if 1 < v && v < 2
      "hit!"
    end
  end
end
```

Maccro comes from "Macro" and "Makkuro"(means "pure black" in Japanese).

### Why Maccro?

* New macro processor can depend on Ruby's new `RubyVM::AbstractSyntaxTree`
  * Macro rules can be interoperable between Ruby versions (but only for Ruby 2.6 or later)
* Todo: Write other reasons

### LIMITATION

Maccro can:

* run with Ruby 2.6 or later
* rewrite code, only written in methods using `def` keyword, in `module` or `class`
* not rewrite singleton methods, which are used just after definition
* not rewrite methods from command line option (`-e`) or REPLs (irb/pry)

Maccro features below are not supported yet:

* Non-idempotent method calls
* Local variable name matching (currntly, local variable name in before/after could be referred as VCALL)
* Applying macro rules Recursively
* Specifying a type of literal by placeholders
* Handling method visibilities
* Rewriting singleton methods with non-self receiver
* Placeholder validation
* Multi time match placeholder

## Usage

Maccro users do:
* register rules how to rewrite methods, with code patterns
  * or use built-in rules
* apply a set of registered rules to a method
* enable automatic applying to a module/class or to a file, or globally

### Terminology

* Rule
  * a definition to rewrite codes, which has a name and two Ruby code snippets of Before and After
* Before
  * a Ruby code snippet to match a pattern of code, which may contain a placeholder or placeholders to capture Ruby codes
* After
  * a Ruby code snippet to replace matched code, which may contain a placeholder or placeholders to inject captured Ruby codes
* Placeholder
  * a bare word in Before/After, to capture/replace Ruby code snippets
  * its format is an alphabetical character and an integer number (>= 1) (e.g, `e1`, `e100`, `v1`)
  * alphabetical characters represents the types of Ruby code (an expression, an value, etc)

### Writing Rules

When you write a new rule, it should have a symbol of unique name, and two Ruby code snippets as String, which represents the code pattern to be rewritten, and the code pattern how to rewrite it.

`Maccro.register(:name_of_this_rule, 'ruby_code_before', 'ruby-code-after')`

"Before" and "After" code snippets must be a valid Ruby code as themselves (that means it can be parsed without syntax error). We can check it using `ruby -cw -e 'code-snippet'`.
For example, the rule below will rewrite `Math.sin(@x)` to `my_own_sin(@x)`.

`Maccro.register(:rewrite_sin_to_mine, 'Math.sin(@x)', 'my_own_sin(@x)')`

This rule matches the code exactly equal to `Math.sin(x)`. The receiver must be the `Math` class, method must be the `Math.sin` and the argument must be the instance variable `@x`.
If you want to rewrite every `Math.sin` calls to `my_own_sin`, arguments should be a placeholder.

`Maccro.register(:rewrite_sin_to_mine, 'Math.sin(e1)', 'my_own_sin(e1)')`

The placeholder `e1` will match to an any expression (which returns a value / values, including literals, variables, function or method calls and if/unless). The `e1` in "Before" captures the actual expression used in the rewritten method definition, and the `e1` in "After" will be replaced with the captured code.

```ruby
# Applying the rule: Maccro.register(:rewrite_sin_to_mine, 'Math.sin(e1)', 'my_own_sin(e1)')

# Before rewrite
def myfunc(x, y, z)
  return [Math.sin(x), Math.sin(x + y), Math.sin(if x > y then z else 0 end)]
end

# After rewrite
def myfunc(x, y, z)
  return [my_own_sin(x), my_own_sin(x + y), my_own_sin(if x > y then z else 0 end)]
end
```

A rule will match to codes of the method as much as possible, and will rewrite all matched pieces.

If the specified placeholder was `v1`, `vN` placeholders matches only with a value (a literal, a local variable, an instance variable, a global variable, etc), so the result will be:

```ruby
# Applying the rule: Maccro.register(:rewrite_sin_to_mine, 'Math.sin(v1)', 'my_own_sin(v1)')

# Before rewrite
def myfunc(x, y, z)
  return [Math.sin(x), Math.sin(x + y), Math.sin(if x > y then z else 0 end)]
end

# After rewrite
def myfunc(x, y, z)
  return [my_own_sin(x), Math.sin(x + y), Math.sin(if x > y then z else 0 end)]
  # 2nd and 3rd expressions doesn't match to the rule
end
```

#### Placeholder details

Placeholders should be the combination of an alphabetic character and an integer. For example, `e1`, `v5`, `v100`, etc. Any integer numbers are available, and there are no need to be continuous numbers (you can use `e2` without `e1`).

Placeholders can be used in both of "Before" and "After" code snippets, and placeholders used in "After" must be in "Before" too to capture codes to be referred in "After" (otherwise, placeholders in "After" will be left as-is).

Types of placeholders are defined by alphabetic chars:

* `v`: values (local variable, instance variable, class variable and global variable, )
  * local variables
  * instance variables
  * class variables
  * global variables
  * thread local variables (e.g., `$1` etc)
  * constants
  * strings
  * regular expressions
  * lambda, array, hash
  * literals (integer, float, symbol, range, nil, true, false, etc)
  * self
* `e`: expressions, any code which returns a value or values (
  * all values (matches to `v`)
  * if, unless, case
  * and, or
  * calls of functions, operators
  * safe call operators (`&.`)
  * super, yield
  * match with regular expressions (`=~`)
  * `defined?`
  * defining methods and singleton methods
  * double and trible colon `::` and `:::`
  * dots and flip-flop

* TODO: implement placeholder for strings
* TODO: implement placeholder for symbols
* TODO: implement placeholder for numbers

#### Using a placeholder twice (or more)

TODO: using a placeholder twice in "Before" is not implemented now (it doesn't work correctly)

If "After" code contains a placeholder twice or more, these placeholders will be replaced with the same code snippet captured in "Before".

```ruby
# Applying the rule: Maccro.register(:define_my_own_power, 'power(e1, 3)', 'e1 * e1 * e1')

# Before rewrite
def myfunc(x)
  return power(x, 3)
end

# After rewrite
def myfunc(x)
  return x * x * x
end
```

#### Rules for non-idempotent methods (methods which has side effects)

If the captured code has side effect and it'll be used more times than "Before", it'll be broken behavior.

```ruby
# Applying the rule: Maccro.register(:define_longer_one, 'longer(e1, e2)', '(e1).length >= (e2).length ? e1 : e2')

# Before rewrite
def myfunc(str1, str2)
  return longer(str1.succ!, str2.succ!)
end

# After rewrite
def myfunc(str1, str2)
  return (str1.succ!).length >= (str2.succ!) ? str1.succ! : str2.succ!
end
```

That may cause unexpected results.

TODO: implement safe_reference option

#### Rules for limited source pattern

If the rule should rewrite the code which is surrounded a pattern of code, the `under` option will help the situation.

```ruby
Macro.register(:rewrite_range_cover, '[e1, v1, e2]', '[(e1)...(e2)].cover?(v1)', under: 'my_dsl_function($TARGET)')'
```

This rule matches to the code in the code captured by `$TARGET`. The placehodler used in `under` option pattern is independent from the placeholders in "Before" and "After".
The example behavior is:

```ruby
# Before rewrite
def myfunc(v)
  if v > 1
    my_dsl_function([1, v, 2] ? 1 : 2)
  else
    [1, v, 2] ? 1 : 2
  end
end

# After rewrite
def myfunc(v)
  if v > 1
    my_dsl_function([(1)...(2)].cover?(v) ? 1 : 2)
  else
    [1, v, 2] ? 1 : 2
  end
end
```

In this example, the `[1, v, 2]` for the case of `v > 1` is afftected by the rule because it's in the code for the argument of `my_dsl_function`, but the other (for else) is not affected because there are no method call of `my_dsl_function`.

### Applying Rules

To apply registered rules on methods manually, call `Maccro.apply` with the module/class and its method. Maccro will try to match all rules to the mthod.

```ruby
# register rules, then
Maccro.apply(MyClass, MyClass.instance_method(:foo))
```

When you want to try the selected rules, call `apply` method with `rules` keyword argument.

```ruby
Maccro.apply(MyClass, MyClass.instance_method(:foo), rules: [:rule1, :rule2, :rule3])
```

### Using Built-in Rules

Maccro has many built-in rules, for continuing less/greater-than or equal-to, for mathematical intervals and ActiveRecord utilities.
You can see the list of built-in rules here: [RULE](https://github.com/tagomoris/maccro/blob/master/lib/maccro/builtin.rb#L5).

```ruby
require 'maccro/builtin'

Maccro::Builtin.register(:built_in_rule_name)

# or register all built-in rules
Maccro::Builtin.register_all
```

Built-in rules can be fetched via `Maccro::Builtin.rule(:name)` or `Maccro::Builtin.rules(:name1, :name2, :name3, ...)`. These rules can be used for `rules` of `Maccro.apply`.

### Enabling Automatic applying

Maccro has a feature to rewrite all defined methods using TracePoint. Users can enable Maccro only for a module/class or only for a path.

```ruby
require 'maccro'
Maccro.register(...)

# enable Maccro for a module (MyModule must be defined before)
Maccro.enable(target: MyModule, rules: [:name1, :name2, ...])

# or, enable Maccro for this file, with all rules registered
Maccro.enable(path: __FILE__)

module MyModule
  # ...
end
```

Without any options, `Maccro.enable` enables all rules globally. That is strongly NOT recommended in libraries.

`Maccro.enable` rewrite all method definitions, defined AFTER `Maccro.enable()`. The methods defined before it will not be updated.

And `Maccro.enable` rewrites methods at the end of module/class definition. So you need to take care about singleton methods which are called in the class/module definition.

For example:

```ruby
Maccro.enable(path: __FILE__, rules: [:rewrite_foo_to_bar])

module MyModule
  def self.foo
    "foo" # this should be rewritten to "bar"
  end

  FOO = self.foo # this value is "foo" here

end # Maccro works here

foo = self.foo # this value is "bar" here
```

To enable Maccro globally to rewrite all defined methods by all registered rules, require the file for that. (That is strongly NOT recommended in libraries too!)

```ruby
require 'maccro/rewrite_the_world'
```

Or run ruby with this library.

```sh
$ ruby -rmaccro/rewrite_the_world file_to_run.rb
```

### API

#### `Maccro#register(name, before, after, **kwarg_options)`

* name: a symbol to represents the rule
* before: a string of Ruby code which matches to be rewritten
* after: a string of Ruby code which replaces the matched part
* kwarg_options:
  * under: a string of Ruby code which matches to limit the affected area (must contain `$TARGET`)
  * safe_reference: TODO: (NOT IMPLEMENTED NOW)

#### `Maccro#apply(module, method, **kwarg_options)`

* module: a module/class, the applied method is defined in
* method: a method object (an instance method or a singleton method)
* kwarg_options:
  * rules: an array of symbols of rule names (default: all registered rules)

#### `Maccro#enable(**kwarg_options)`

* kwarg_options:
  * target: a module/class to enable Maccro to rewrite all methods defined (exclusive with path)
  * path: a file path to enable Maccro to rewrite all methods defined (exclusive with target)
  * rules: an array of symbols of rule names (default: all registered rules)

`Maccro.enable` can be called for different targets or paths, but calling twice for the same target/path would make troubles.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tagomoris/maccro.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

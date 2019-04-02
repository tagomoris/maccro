# Maccro

Maccro is a library to introduce macro (dynamic code rewriting), written in Ruby 100%.

```ruby
Maccro.register(:double_littler_than, 'e1 < e2 < e3', 'e1 < e2 && e2 < e3')

# This rewrites this code
if 1 < v < 2
  "hit!"
end

# To this (valid Ruby) code dynamically
if 1 < v && v < 2
  "hit!"
end
```

Maccro comes from "Macro" and "Makkuro" (pure black in Japanese).

### LIMITATION

Maccro can:

* run with Ruby 2.6 or later
* rewrite code, only written in methods using `def` keyword

TODO: add other limitations

## Usage

TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tagomoris/maccro.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# ruby-d4

:cat: [d4](https://github.com/38/d4-format) - Dense Depth Data Dump - for Ruby

## Installation

```
git clone https://github.com/kojix2/ruby-d4
cd ruby-d4
bundle exec rake d4:build
bundle exec rake install
```

## Usage

```ruby
require 'd4'
```

## Development

- [Ruby-FFI](https://github.com/ffi/ffi)
- [c2ffi](https://github.com/rpav/c2ffi)
- [c2ffi4rb](https://github.com/kojix2/c2ffi4rb)

Generate FFI binding using c2ffi.

```
c2ffi d4-format/d4binding/include/d4.h | c2ffi4rb > lib/d4/ffi2.rb
# edit lib/d4/ffi2.rb
```

## License

MIT

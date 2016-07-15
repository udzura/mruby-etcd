# mruby-etcd   [![Build Status](https://travis-ci.org/udzura/mruby-etcd.svg?branch=master)](https://travis-ci.org/udzura/mruby-etcd)
Etcd class
## install by mrbgems
- add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'udzura/mruby-etcd'
end
```
## example
```ruby
p Etcd.hi
#=> "hi!!"
t = Etcd.new "hello"
p t.hello
#=> "hello"
p t.bye
#=> "hello bye"
```

## License
under the MIT License:
- see LICENSE file

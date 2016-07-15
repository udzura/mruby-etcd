# mruby-etcd [![Build Status](https://travis-ci.org/udzura/mruby-etcd.svg?branch=master)](https://travis-ci.org/udzura/mruby-etcd)

Simple etcd API implementation

## Install by mrbgems

Add conf.gem line to `build_config.rb`

```ruby
MRuby::Build.new do |conf|

  # ... (snip) ...

  conf.gem :github => 'udzura/mruby-etcd'
end
```

## example

```ruby
c = Etcd::Client.new

c.put "foo", "1"
# => {"action"=>"set", "node"=>{"key"=>"/foo, "value"=>"1", "modifiedIndex"=>15, "createdIndex"=>15}}

c.get "foo"
#=> "1"

c.get "notfound", true # for raw resp.
# => {"errorCode"=>100, "message"=>"notfound", "cause"=>"/ping", "index"=>14}

c.list("foo2")
# => {"action"=>"get", "node"=>{"key"=>"/foo2", "dir"=>true, "nodes"=>[{"key"=>"/foo2/bar", "value"=>"", "modifiedIndex"=>8, "createdIndex"=>8}], "modifiedIndex"=>7, "createdIndex"=>7}}

c.stats
# => {"name"=>"localhost", "id"=>"ce2a822cea30bfca", "state"=>"StateLeader", "startTime"=>"2016-07-14T22:01:24.295148325-07:00", "leaderInfo"=>{"leader"=>"ce2a822cea30bfca", "uptime"=>"2h52m59.95401830

c.wait("bar")
# ...
# Another process; c.put "bar", "yo"
# Then return
#  => {"action"=>"set", "node"=>{"key"=>"/bar", "value"=>"yo", "modifiedIndex"=>23, "createdIndex"=>23}, "prevNode"=>{"key"=>"/bar", "value"=>"Oreore2", "modifiedIndex"=>13, "createdIndex"=>13}}

c.wait("foo2", true) # For directory
```

See official API reference. [That's it](https://coreos.com/etcd/docs/latest/api.html).

## License

Under the MIT License: see LICENSE file

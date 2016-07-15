##
## Etcd Test
##

assert("Etcd#hello") do
  t = Etcd.new "hello"
  assert_equal("hello", t.hello)
end

assert("Etcd#bye") do
  t = Etcd.new "hello"
  assert_equal("hello bye", t.bye)
end

assert("Etcd.hi") do
  assert_equal("hi!!", Etcd.hi)
end

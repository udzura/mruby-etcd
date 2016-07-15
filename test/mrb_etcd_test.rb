assert("Etcd::Client.new") do
  c = Etcd::Client.new
  assert_equal("http://127.0.0.1:2379/v2", c.endpoint)
end

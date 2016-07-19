MRuby::Gem::Specification.new('mruby-etcd') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Uchio Kondo'
  spec.version = "0.1.0"
  spec.summary = 'Simple etcd API implementation'

  spec.add_dependency 'mruby-httprequest', :mgem => 'mruby-httprequest'
  spec.add_dependency 'mruby-iijson',      :github => 'udzura/mruby-iijson', :branch => 'patch-1'
end

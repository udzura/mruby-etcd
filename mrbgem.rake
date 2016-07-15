MRuby::Gem::Specification.new('mruby-etcd') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Uchio Kondo'

  spec.add_dependency 'mruby-httprequest', :mgem => 'mruby-httprequest'
  spec.add_dependency 'mruby-iijson',      :mgem => 'mruby-iijson'
end

load File.expand_path('../mrblib/etcd/version.rb', __FILE__)

MRuby::Gem::Specification.new('mruby-etcd') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Uchio Kondo'
  spec.version = Etcd::VERSION
  spec.summary = 'Simple etcd API implementation'

  spec.add_dependency 'mruby-httprequest', :mgem => 'mruby-httprequest'
  spec.add_dependency 'mruby-iijson',      :mgem => 'mruby-iijson'
end

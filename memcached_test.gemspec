# coding: UTF-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memcached_test/version'

Gem::Specification.new do |spec|
    spec.name        = 'memcached_test'
    spec.version     = MemcachedTest::VERSION
    spec.authors     = ['Matias Caporale']
    spec.email       = 'matiascaporale9@gmail.com'
    spec.summary     = 'Test of a memcached server'
    spec.description = 'Test of a memcached server for coding challenge'
    spec.date        = '2020-06-29'
    spec.homepage    = 'https://rubygems.org/gems/memcached_test'
    spec.license     = 'MIT'

    spec.files         = Dir.glob('{lib}/**/*')
    spec.test_files    = Dir.glob('{spec}/**/*').grep(%r{^spec/})
    spec.require_paths = %w[lib]
    spec.bindir        = 'bin'
    spec.executables   = ['memcached_test_client', 'memcached_test_server']

    spec.add_development_dependency('rspec', '~> 2.12')
end
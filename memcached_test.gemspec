# coding: UTF-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
    spec.name        = 'memcached_test'
    spec.version     = '0.0.1'
    spec.authors     = ['Matias Caporale']
    spec.email       = 'matiascaporale9@gmail.com'
    spec.summary     = 'Test of a memcached server'
    spec.description = 'Test of a memcached server for coding challenge'
    spec.date        = '2020-06-20'
    spec.homepage    = 'https://rubygems.org/gems/memcached_test'
    spec.license     = 'MIT'

    spec.files         = Dir.glob('{lib}/**/*')
    spec.test_files    = Dir.glob('{spec}/**/*').grep(%r{^spec/})
    spec.require_paths = %w[lib]
    spec.bindir        = 'bin'
    spec.executables   = ['client', 'server']

    spec.add_development_dependency('rspec', '~> 2.12')
end
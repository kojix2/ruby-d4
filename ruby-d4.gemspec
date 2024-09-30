require_relative 'lib/d4/version'

Gem::Specification.new do |spec|
  spec.name = 'ruby-d4'
  spec.version = D4::VERSION
  spec.authors = ['kojix2']
  spec.email = ['2xijok@gmail.com']

  spec.summary = 'd4'
  spec.description = 'd4'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.files         = Dir['*.{md,txt}', '{lib}/**/*', 'vendor/*.{so,dylib,dll}']
  spec.require_path  = 'lib'
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi'
end

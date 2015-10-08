# -*- encoding: utf-8 -*-
require File.expand_path('../lib/clean_config/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'clean_config'
  spec.version       = CleanConfig::VERSION
  spec.summary       = 'A simple configuration library'
  spec.description   = 'Provides programatic access to config/config.yml'
  spec.homepage      = 'http://github.com/opower/orb_configuration'

  spec.authors       = ['John Crimmins', 'Crystal Hsiung', 'Adrian Cazacu']
  spec.email         = ['john.crimmins@opower.com']

  # This gem will work with 1.9.3 or greater...
  spec.required_ruby_version = '>= 1.9.3'

  spec.license       = 'Apache 2'

  # file attributes...
  spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_development_dependency('rake', '~> 10.1')
  spec.add_development_dependency('rspec', '~> 3.1')
  spec.add_development_dependency('rspec-legacy_formatters', '~> 1.0')
  spec.add_development_dependency('rspec-extra-formatters', '~> 1.0')
  spec.add_development_dependency('rubocop', '= 0.26.1')
  spec.add_development_dependency('fuubar', '~> 2.0')
  spec.add_development_dependency('yard')
  spec.add_development_dependency('redcarpet')
  spec.add_development_dependency('simplecov', '~> 0.7')

  spec.add_runtime_dependency('recursive-open-struct', '~> 0.5')
  # We're using deep_merge which is available in all versions of activesupport so far.
  spec.add_runtime_dependency('activesupport', '< 5.0')
end

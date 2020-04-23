# frozen_string_literal: true

require_relative 'lib/chained_job/version'

Gem::Specification.new do |spec|
  spec.name      = 'chained_job'
  spec.version   = ChainedJob::VERSION
  spec.summary   = 'Chained job helper'
  spec.homepage  = 'https://github.com/vinted/chained_job'
  spec.authors   = ['Mantas Kūjalis']
  spec.email     = ['mantas.kujalis@vinted.com']
  spec.license   = 'MIT'

  spec.files         = Dir.glob('lib/**/*')
  spec.executables   = Dir.glob('bin/**/*').map { |path| path.gsub('bin/', '') }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop-vinted', '~> 0.3'
end

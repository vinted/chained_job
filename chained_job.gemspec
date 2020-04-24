# frozen_string_literal: true

require_relative 'lib/chained_job/version'

Gem::Specification.new do |spec|
  spec.name = 'chained_job'
  spec.version = ChainedJob::VERSION
  spec.summary = 'Chained job helper'
  sepc.description = 'Chained job allows you to define an array of queued jobs that should be ' \
      'run in sequence after the main job has been executed successfully.'
  spec.homepage = 'https://github.com/vinted/chained_job'
  spec.authors = ['Mantas Kūjalis', 'Titas Norkūnas']
  spec.email = ['mantas.kujalis@vinted.com', 'titas@vinted.com']
  spec.license = 'MIT'

  spec.files = Dir.glob('lib/**/*')
  spec.executables = Dir.glob('bin/**/*').map { |path| path.gsub('bin/', '') }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop-vinted', '~> 0.3'
end

# frozen_string_literal: true

require_relative 'lib/chained_job/version'

Gem::Specification.new do |spec|
  spec.name = 'chained_job'
  spec.version = ChainedJob::VERSION
  spec.summary = 'Chained job helper'
  spec.description = 'Chained job allows you to define an array of queued jobs that should be ' \
      'run in sequence after the main job has been executed successfully.'
  spec.homepage = 'https://github.com/vinted/chained_job'
  spec.authors = ['Vinted']
  spec.email = ['backend@vinted.com']
  spec.license = 'MIT'

  spec.files = Dir.glob('lib/**/*')
  spec.executables = Dir.glob('bin/**/*').map { |path| path.gsub('bin/', '') }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
end

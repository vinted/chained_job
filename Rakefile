# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |task|
  task.test_files = FileList['test/**/*_test.rb']
  task.libs += %w(test lib)
end

task default: :test

task :version do |t|
  puts ChainedJob::VERSION
end

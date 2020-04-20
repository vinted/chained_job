# frozen_string_literal: true

require 'bundler/gem_tasks'

# Do not allow releases just yet
Rake::Task['release'].clear

require 'rake/testtask'

Rake::TestTask.new(:test) do |task|
  task.test_files = FileList['test/**/*_test.rb']
  task.libs += %w(test lib)
end

task default: :test

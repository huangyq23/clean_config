#!/usr/bin/env rake
# Please note this file does not use the test_support gem because test_support depends on orb_configuration.
# As a work-around to avoid a circular-dependency, we're rolling our own task code here.
# This is a special case. The vast majority of projects should be using test_support to provide Rspec tasks.
require 'rspec'
require 'rspec/core/rake_task'
require 'rspec-extra-formatters'
require 'fuubar'
require 'rubocop/rake_task'
require 'logger'

TMP_DIR = 'tmp'
LOG = Logger.new(open('rake.log', File::WRONLY | File::APPEND | File::CREAT))

desc 'Run RuboCop on lib and spec directories, Gemfile, gemspec, Rakefile; Override with a space delimited list'
RuboCop::RakeTask.new(:rubocop, :pattern) do |task, args|
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb', 'Gemfile', '*.gemspec', 'Rakefile']
  task.patterns = args[:pattern].split(' ') if args[:pattern] # override default pattern
  LOG.info("Running RuboCop against #{task.patterns}")
end

def timestamp
  Time.now.strftime('%Y%m%d_%H%M%S')
end

def build_rspec_opts(test_type, task)
  task.rspec_opts = ['-c']
  task.rspec_opts << '--require' << 'fuubar'
  task.rspec_opts << '--format' << Fuubar
  task.rspec_opts << '--require' << 'rspec/legacy_formatters'
  task.rspec_opts << '--require' << 'rspec-extra-formatters'
  task.rspec_opts << '--format' << JUnitFormatter
  task.rspec_opts << '--out' << "tmp/results/#{test_type}/#{timestamp}_results.xml"
  task.rspec_opts << '--format' << 'html'
  task.rspec_opts << '--out' << "tmp/results/#{test_type}/#{timestamp}_results.html"
  task.pattern = "spec/#{test_type}/**/*_spec.rb"
end

namespace :clean do
  desc 'Remove all tmp files'
  task :tmp do
    LOG.info("Deleting the #{TMP_DIR} directory...")
    FileUtils.rm_rf(TMP_DIR)
    LOG.info('Deleted.')
  end
end

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |task|
    FileUtils.mkdir_p(TMP_DIR)
    build_rspec_opts('unit', task)
  end

  RSpec::Core::RakeTask.new(:e2e) do |task|
    FileUtils.mkdir_p(TMP_DIR)
    build_rspec_opts('e2e', task)
  end

  desc 'Run all tests'
  task full: %w(clean:tmp spec:unit spec:e2e)
end

LOG.close

# TODO: make spec_helper_gem and spec_helper_test. Take coverage out of test.
require 'simplecov'

SimpleCov.start do
  coverage_dir 'tmp/coverage/unit'
  add_filter 'tmp/'
  add_filter 'spec/'
end

RSpec.configure do |config|
  # Only accept expect syntax do not allow old should syntax
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

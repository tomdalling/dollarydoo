require_relative "../lib/boot.rb"
require "rspec/example_steps"
require "byebug"

RSpec.configure do |config|
  # rspec-core
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed

  # rspec-expectations
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # custom stuff
  config.default_formatter = "doc" if config.files_to_run.one?
  config.alias_example_group_to :feature, feature: true
  config.alias_example_to :scenario
end

require File.expand_path("../../spec/dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

$:.push File.expand_path("../../lib", __FILE__)
require 'websocket-rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["./spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    WebsocketRails.config.logger = Logger.new(StringIO.new)
  end
end

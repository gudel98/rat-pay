require "karafka/testing/rspec/helpers"
require "rspec/mocks"

World(Karafka::Testing::RSpec::Helpers)
World(RSpec::Mocks::ExampleMethods)

Before do
  RSpec::Mocks.setup

  Karafka::App.config.kafka[:seed_brokers] = []
  Karafka::App.config.consumer_persistence = false

  allow_any_instance_of(WaterDrop::Producer).to receive(:produce_async).and_return(true)
end

After do
  RSpec::Mocks.verify
  RSpec::Mocks.teardown
end

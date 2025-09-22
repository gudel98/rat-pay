require "rails_helper"
require "karafka/testing/rspec/helpers"

RSpec.describe PaymentsConsumer, type: :consumer do
  include Karafka::Testing::RSpec::Helpers

  before do
    Karafka.producer.produce_sync(
      topic: "payments",
      payload: { id: 123, amount: "2000", currency: "EUR" }.to_json
    )
  end

  it { expect(karafka.produced_messages.size).to eq(1) }
  it { expect(karafka.produced_messages.first[:topic]).to eq('payments') }
end

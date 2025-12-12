require "rails_helper"

RSpec.describe ProcessingWorker, type: :worker do
  include ActionView::RecordIdentifier

  let(:transaction) { create(:transaction, amount: amount, status: "pending") }

  before do
    allow_any_instance_of(described_class).to receive(:sleep) # skip processing sleep
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
    allow_any_instance_of(WaterDrop::Producer).to receive(:produce_async)
  end

  shared_examples "broadcasts status" do |expected_status|
    it "updates status and broadcasts turbo stream" do
      described_class.new.perform(transaction.id)

      expect(transaction.reload.status).to eq(expected_status)
      expect(Turbo::StreamsChannel).to have_received(:broadcast_replace_to).with(
        transaction,
        hash_including(
          target: dom_id(transaction, :status),
          partial: "payments/status",
          formats: [ :turbo_stream ],
          locals: hash_including(
            transaction: transaction,
            response: hash_including(status: expected_status)
          )
        )
      )
    end
  end

  context "when amount is 2000 (successful)" do
    let(:amount) { 2000 }
    include_examples "broadcasts status", "successful"
  end

  context "when amount is 3000 (declined)" do
    let(:amount) { 3000 }
    include_examples "broadcasts status", "declined"
  end

  context "when amount is other (processing error with retry)" do
    let(:amount) { 4000 }

    it "retries and eventually fails calling the exhausted hook" do
      expect {
        described_class.new.perform(transaction.id)
      }.to raise_error(ProcessingWorker::ProcessingError)

      # Sidekiq::Testing doesn't run the full retry lifecycle automatically
      described_class.sidekiq_retries_exhausted_block.call(
        { "args" => [transaction.id] },
        ProcessingWorker::ProcessingError.new("Temporary processing failure")
      )

      expect(transaction.reload.status).to eq("failed")
    end
  end
end

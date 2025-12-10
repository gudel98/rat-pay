require "rails_helper"

RSpec.describe ProcessingWorker, type: :worker do
  include ActionView::RecordIdentifier

  let(:transaction) { create(:transaction, amount: amount, status: "pending") }

  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
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

  context "when amount is other (failed)" do
    let(:amount) { 1500 }
    include_examples "broadcasts status", "failed"
  end
end

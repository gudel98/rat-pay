require "rails_helper"

RSpec.describe ProcessingService do
  let(:params) { { amount: amount, currency: "EUR" } }

  before do
    allow_any_instance_of(described_class).to receive(:sleep) # fast specs
    allow_any_instance_of(WaterDrop::Producer).to receive(:produce_sync)
    allow(Transaction).to receive(:create!).with(params).and_return(transaction_double)
  end

  describe ".call" do
    subject { described_class.call(params) }

    context "when transaction is verified" do
      let(:transaction_double) { instance_double("Transaction", id: 1, verified?: true, update: nil) }
      let(:amount) { 2000 }
      let(:successful_response) { { status: "successful", message: "Transaction complete." } }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "verified" }) }

      it "processes with acquirer and updates transaction" do
        result = subject

        expect(Transaction).to have_received(:create!).with(params)
        expect(AntiFraudService).to have_received(:call)
        expect(transaction_double).to have_received(:update).twice
        expect(transaction_double).to have_received(:verified?)
        expect(result).to eq(successful_response)
      end
    end

    context "when transaction verification fails" do
      let(:transaction_double) { instance_double("Transaction", verified?: false, update: nil) }
      let(:amount) { 100 }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "failed", message: "Blocked by AF" }) }

      it "returns verification response without calling acquirer" do
        result = subject

        expect(transaction_double).to have_received(:update).once
        expect(AntiFraudService).to have_received(:call)
        expect(result).to eq({ status: "failed", message: "Blocked by AF" })
      end
    end

    context "processing returns declined" do
      let(:transaction_double) { instance_double("Transaction", id: 1, verified?: true, update: nil) }
      let(:amount) { 3000 }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "verified" }) }

      it "returns declined response when amount is 3000" do
        result = subject

        expect(result).to eq({ status: "declined", message: "Transaction declined: Insufficient funds." })
      end
    end

    context "processing returns failed" do
      let(:transaction_double) { instance_double("Transaction", id: 1, verified?: true, update: nil) }
      let(:amount) { 999 }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "verified" }) }

      it "returns failed response for other amounts" do
        result = subject

        expect(result).to eq({ status: "failed", message: "Transaction failed: Processing error." })
      end
    end
  end
end

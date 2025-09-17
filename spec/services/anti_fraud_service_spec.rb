require "rails_helper"

RSpec.describe AntiFraudService do
  let(:transaction) { create(:transaction, amount: amount) }
  let(:service) { described_class.new(transaction) }

  before { allow_any_instance_of(described_class).to receive(:sleep) }

  describe "#verify" do
    subject { service.verify }

    context "when transaction amount is not 100" do
      let(:amount) { 99 }

      it "returns verified status" do
        expect(subject).to eq({ status: "verified", message: "Transaction verified." })
      end
    end

    context "when transaction amount is 100" do
      let(:amount) { 100 }

      it "returns failed status and logs error" do
        expect(Rails.logger).to receive(:error).with(/\[Anti-Fraud exception\] AF Alert/)
        expect(subject).to eq({ status: "failed", message: "Transaction failed: Blocked by Anti-Fraud system." })
      end
    end
  end
end

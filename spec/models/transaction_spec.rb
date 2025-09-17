require "rails_helper"

RSpec.describe Transaction, type: :model do
  describe "validations" do
    it { should validate_presence_of(:amount) }
    it { should validate_comparison_of(:amount).is_greater_than(0) }
    it { should validate_presence_of(:currency) }

    it "allows supported currencies" do
      Transaction::SUPPORTED_CURRENCIES.each do |currency|
        expect(build(:transaction, currency: currency)).to be_valid
      end
    end

    let(:txn_with_unsupported_currency) { build(:transaction, currency: "JPY") }

    it "does not allow unsupported currencies" do
      expect(txn_with_unsupported_currency).not_to be_valid
      expect(txn_with_unsupported_currency.errors[:currency]).to include("is not supported.")
    end
  end

  describe "#verify!" do
    let(:transaction) { create(:transaction, amount: 100, currency: "USD") }
    let(:verification_response) { { status: "verified" } }

    subject { transaction.verify! }

    it "calls AntiFraudService with the transaction" do
      expect(AntiFraudService).to receive(:call)
        .with(transaction)
        .and_return(verification_response)

      subject

      expect(transaction.status).to eq("verified")
    end
  end

  describe "#process!" do
    let(:transaction) { create(:transaction, amount: 100, currency: "USD") }
    let(:processing_response) { { status: "processed" } }

    subject { transaction.process!(processing_response) }

    it "updates the status from the given processing response" do
      subject

      expect(transaction.status).to eq("processed")
    end
  end

  describe "#verified?" do
    let(:verified_txn) { build(:transaction, status: "verified") }
    let(:pending_txn)  { build(:transaction, status: "pending") }

    it "returns true if status is 'verified'" do
      expect(verified_txn.verified?).to be true
    end

    it "returns false otherwise" do
      expect(pending_txn.verified?).to be false
    end
  end
end

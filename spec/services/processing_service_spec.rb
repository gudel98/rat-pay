require "rails_helper"

RSpec.describe ProcessingService do
  let(:params) { { amount: amount, currency: "EUR" } }

  before do
    allow_any_instance_of(described_class).to receive(:sleep) # fast specs
    allow(Transaction).to receive(:create!).with(params).and_return(transaction_double)
  end

  describe ".call" do
    subject { described_class.call(params) }

    context "when transaction is verified" do
      let(:transaction_double) { instance_double("Transaction",
                                                 verify!: { status: "verified" },
                                                 verified?: true,
                                                 process!:  nil) }
      let(:amount) { 2000 }
      let(:successful_response) { { status: "successful", message: "Transaction complete." } }

      it "processes with acquirer and updates transaction" do
        result = subject

        expect(Transaction).to have_received(:create!).with(params)
        expect(transaction_double).to have_received(:verify!)
        expect(transaction_double).to have_received(:verified?)
        expect(transaction_double).to have_received(:process!).with(successful_response)
        expect(result).to eq(successful_response)
      end
    end

    context "when transaction verification fails" do
      let(:transaction_double) { instance_double("Transaction",
                                                 verify!: { status: "failed", message: "Blocked by AF" },
                                                 verified?: false,
                                                 process!:  nil) }
      let(:amount) { 100 }

      it "returns verification response without calling acquirer" do
        result = subject

        expect(transaction_double).to have_received(:verify!)
        expect(transaction_double).not_to have_received(:process!)
        expect(result).to eq({ status: "failed", message: "Blocked by AF" })
      end
    end

    context "acquirer_processing! returns declined" do
      let(:transaction_double) { instance_double("Transaction",
                                                 verify!: { status: "verified" },
                                                 verified?: true,
                                                 process!:  nil) }
      let(:amount) { 3000 }

      it "returns declined response when amount is 3000" do
        result = subject

        expect(result).to eq({ status: "declined", message: "Transaction declined: Insufficient funds." })
      end
    end

    context "acquirer_processing! returns failed" do
      let(:transaction_double) { instance_double("Transaction",
                                                 verify!: { status: "verified" },
                                                 verified?: true,
                                                 process!:  nil) }
      let(:amount) { 999 }

      it "returns failed response for other amounts" do
        result = subject

        expect(result).to eq({ status: "failed", message: "Transaction failed: Processing error." })
      end
    end
  end
end

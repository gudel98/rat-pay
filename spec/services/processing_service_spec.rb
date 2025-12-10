require "rails_helper"
require "memory_profiler"

RSpec.describe ProcessingService do
  let(:params) { { amount: amount, currency: "EUR" } }
  let(:transaction_double) do
    instance_double(
      "Transaction",
      id: 1,
      verified?: verified?,
      successful?: successful?,
      update: nil,
      amount: amount,
      currency: "EUR"
    )
  end

  before do
    allow_any_instance_of(described_class).to receive(:sleep) # fast specs
    allow_any_instance_of(WaterDrop::Producer).to receive(:produce_async)
    allow(ProcessingWorker).to receive(:perform_async)
  end

  subject do
    described_class.new.call(params) do |m|
      m.failure :validate_currency do |exception|
        Rails.logger.error "#{exception.message}\nCurrency: #{params[:currency]}"
        { status: "failed", message: "Invalid currency code: #{params[:currency]}" }
      end

      m.failure :create_txn do |exception|
        Rails.logger.error "#{exception.message}\n#{exception.backtrace.join("\n")}"
        { status: "failed", message: "Transaction cannot be created: #{exception.message}" }
      end

      m.failure { |failed_response| failed_response }
      m.success { |successful_response| successful_response }
    end
  end

  context "when cannot create transaction" do
    let(:amount) { 2000 }
    let(:error_response) { { status: "failed", message: "Transaction cannot be created: Record invalid" } }

    before { allow(Transaction).to receive(:create!).and_raise(ActiveRecord::RecordInvalid) }

    it "processes with acquirer and updates transaction" do
      result = subject

      expect(Transaction).to have_received(:create!)
      expect(result).to eq(error_response)
    end
  end

  describe ".call" do
    before { allow(Transaction).to receive(:create!).with(params).and_return(transaction_double) }

    context "when transaction is verified" do
      let(:amount) { 2000 }
      let(:verified?) { true }
      let(:successful?) { true }
      let(:pending_response) { { status: "pending", message: "Transaction is pending." } }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "verified" }) }

      it "processes with acquirer and updates transaction" do
        result = subject

        expect(Transaction).to have_received(:create!).with(params)
        expect(AntiFraudService).to have_received(:call)
        expect(transaction_double).to have_received(:update).twice
        expect(transaction_double).to have_received(:verified?)
        expect(result).to include(pending_response)
      end

      context "when monitoring memory leaks and allocations" do
        let(:threshold) { 1_048_576 } # 1 Mb

        it 'does not bloat memory' do
          report = MemoryProfiler.report { subject }
          # report.pretty_print(to_file: 'log/memory_report.txt', scale_bytes: true)
          expect(report.total_allocated_memsize).to be < threshold
        end
      end
    end

    context "when transaction verification fails" do
      let(:amount) { 100 }
      let(:verified?) { false }
      let(:successful?) { false }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "failed", message: "Blocked by AF" }) }

      it "returns verification response without calling acquirer" do
        result = subject

        expect(transaction_double).to have_received(:update).once
        expect(AntiFraudService).to have_received(:call)
        expect(result).to eq({ status: "failed", message: "Blocked by AF" })
      end
    end

    context "processing returns declined" do
      let(:amount) { 3000 }
      let(:verified?) { true }
      let(:successful?) { false }
      let(:pending_response) { { status: "pending", message: "Transaction is pending." } }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "verified" }) }

      it "returns pending response when amount is 3000" do
        result = subject

        expect(result).to include(pending_response)
      end
    end

    context "processing returns failed" do
      let(:amount) { 999 }
      let(:verified?) { true }
      let(:successful?) { false }
      let(:pending_response) { { status: "pending", message: "Transaction is pending." } }

      before { allow(AntiFraudService).to receive(:call).and_return({ status: "verified" }) }

      it "returns pending response for other amounts" do
        result = subject

        expect(result).to include(pending_response)
      end
    end
  end
end

class AntiFraudService
  attr_reader :transaction

  def self.call(transaction)
    new(transaction).verify
  end

  def initialize(transaction)
    @transaction = transaction
  end

  def verify
    sleep 1 # emulating communication with an external AF service
    raise StandardError.new("AF Alert") if transaction.amount == 100

    { status: "verified", message: "Transaction verified." }
  rescue StandardError => error
    Rails.logger.error "[Anti-Fraud exception] #{error.message}"
    { status: "failed", message: "Transaction failed: Blocked by Anti-Fraud system." }
  end
end

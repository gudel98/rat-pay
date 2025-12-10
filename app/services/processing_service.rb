require "dry/transaction"

class ProcessingService
  include Dry::Transaction

  try  :validate_currency, catch: ::Money::Currency::UnknownCurrency
  try  :create_txn,        catch: ActiveRecord::RecordInvalid
  step :verify
  step :process
  tee  :notify

  private

  def validate_currency(params)
    ::Money::Currency.new(params[:currency])
    params
  end

  def create_txn(params)
    transaction = Transaction.create!(params)
  end

  def verify(transaction)
    verification_response = AntiFraudService.call(transaction)
    transaction.update(status: verification_response[:status])

    transaction.verified? ? Success(transaction) : Failure(verification_response)
  end

  def process(transaction)
    ProcessingWorker.perform_async(transaction.id)
    transaction.update(status: pending_response[:status])

    Success(pending_response.merge(transaction: transaction))
  end

  def notify(response)
    transaction = response[:transaction]
    Rails.logger.info "Enqueueing payment #{transaction.id} to Kafka..."
    $waterdrop_producer.produce_async(
      payload: { id: transaction.id, amount: transaction.amount, currency: transaction.currency }.to_json,
      topic: "payments"
    )
    Rails.logger.info "Enqueued payment #{transaction.id} to Kafka."
  rescue StandardError => error
    Rails.logger.error "Failed to produce to Kafka: #{error.message}"
  end

  def pending_response
    { status: "pending", message: "Transaction is pending." }
  end
end

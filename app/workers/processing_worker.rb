class ProcessingWorker
  include Sidekiq::Worker
  include ActionView::RecordIdentifier

  attr_reader :transaction, :response

  class ProcessingError < StandardError; end

  sidekiq_options retry: 1
  sidekiq_retries_exhausted do |msg, exception|
    transaction = Transaction.find(msg["args"].first)
    transaction.update(status: "failed")

    Rails.logger.error "[ProcessingWorker] Transaction ##{transaction.id} moved to failed status after retries exhausted. Error: #{exception&.message}"
  end

  def perform(transaction_id)
    @transaction = Transaction.find(transaction_id)

    unless transaction.finalized?
      @response = acquirer_processing!
      transaction.update(status: response[:status])

      Rails.logger.info "[ProcessingWorker] Transaction ##{transaction_id} processed. Status: #{response[:status]}."

      notify_customer! if transaction.finalized?
      broadcast_status!
    end
  rescue ActiveRecord::RecordNotFound => error
    Rails.logger.error "[ProcessingWorker] Transaction ##{transaction_id} not found."
  end

  private

  def acquirer_processing!
    sleep rand(1..3).seconds # emulate communication with acquirer

    case transaction.amount
    when 2000 then { status: "successful", message: "Transaction complete." }
    when 3000 then { status: "declined", message: "Transaction declined: Insufficient funds." }
    else           raise ProcessingError, "Transaction failed: Processing error."
    end
  end

  def broadcast_status!
    Turbo::StreamsChannel.broadcast_replace_to(
      transaction,
      target: dom_id(transaction, :status),
      partial: "payments/status",
      locals: {
        transaction: transaction,
        response: response.merge(transaction: transaction)
      },
      formats: [ :turbo_stream ]
    )
  end

  def notify_customer!
    Rails.logger.info "Enqueueing #{transaction.status} payment #{transaction.id} to Kafka..."
    $waterdrop_producer.produce_async(
      payload: {
        id: transaction.id,
        status: transaction.status,
        amount: transaction.amount,
        currency: transaction.currency
      }.to_json,
      topic: "payments"
    )
    Rails.logger.info "Enqueued #{transaction.status} payment #{transaction.id} to Kafka."
  rescue StandardError => error
    Rails.logger.error "Failed to produce to Kafka: #{error.message}"
  end
end

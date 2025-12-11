class ProcessingWorker
  include Sidekiq::Worker
  include ActionView::RecordIdentifier

  def perform(transaction_id)
    @transaction = Transaction.find(transaction_id)

    unless @transaction.finalized?
      response = acquirer_processing!
      @transaction.update(status: response[:status])

      Rails.logger.info "[ProcessingWorker] Transaction ##{@transaction.id} processed. Status: #{response[:status]}."
      broadcast_status(response)
    end
  rescue ActiveRecord::RecordNotFound => error
    Rails.logger.error "[ProcessingWorker] Transaction ##{@transaction.id} not found."
  end

  private

  def acquirer_processing!
    sleep 2.5 # emulate communication with acquirer

    case @transaction.amount
    when 2000 then { status: "successful", message: "Transaction complete." }
    when 3000 then { status: "declined", message: "Transaction declined: Insufficient funds." }
    else           { status: "failed", message: "Transaction failed: Processing error." }
    end
  end

  def broadcast_status(response)
    Turbo::StreamsChannel.broadcast_replace_to(
      @transaction,
      target: dom_id(@transaction, :status),
      partial: "payments/status",
      locals: {
        transaction: @transaction,
        response: response.merge(transaction: @transaction)
      },
      formats: [ :turbo_stream ]
    )
  end
end

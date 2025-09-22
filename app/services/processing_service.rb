class ProcessingService
  attr_reader :params

  def self.call(params)
    new(params).process
  end

  def initialize(params)
    @params = params
  end

  # TODO: I used to work with dry-validation/dry-transaction
  # for more convinient rails-way pipeline,
  # but let's keep it simple there for demo purpose.
  def process
    transaction = Transaction.create!(params)

    verification_response = verify!(transaction)
    return verification_response unless transaction.verified?

    process!(transaction)
  rescue Exception => error
    Rails.logger.error "#{error.message}\n#{error.backtrace.join("\n")}"
    { status: "failed", message: "Transaction failed. #{error.message}" }
  end

  private

  def verify!(transaction)
    AntiFraudService.call(transaction).tap do |verification_response|
      transaction.update(status: verification_response[:status])
    end
  end

  def process!(transaction)
    acquirer_processing.tap do |processing_response|
      notify_customer!(transaction.id) # Kafka demo notification
      transaction.update(status: processing_response[:status])
    end
  end

  def acquirer_processing
    sleep 0.5 # emulate communication with acquirer

    case params[:amount].to_i
    when 2000 then { status: "successful", message: "Transaction complete." }
    when 3000 then { status: "declined", message: "Transaction declined: Insufficient funds." }
    else           { status: "failed", message: "Transaction failed: Processing error." }
    end
  end

  def notify_customer!(txn_id)
    Rails.logger.info "Enqueueing payment #{txn_id} to Kafka..."
    $waterdrop_producer.produce_sync(
      payload: { id: txn_id, amount: params[:amount], currency: params[:currency] }.to_json,
      topic: "payments"
    )
    Rails.logger.info "Enqueued payment #{txn_id} to Kafka."
  rescue => e
    Rails.logger.error "Failed to produce to Kafka: #{e.message}"
  end
end

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
    verification_response = transaction.verify!

    if transaction.verified?
      acquirer_processing!.tap do |processing_response|
        transaction.process!(processing_response)
      end
    else
      verification_response
    end
  rescue Exception => error
    Rails.logger.error "#{error.message}\n#{error.backtrace.join("\n")}"
    { status: "failed", message: "Transaction failed. #{error.message}" }
  end

  private

  def acquirer_processing!
    sleep 0.5 # emulate communication with acquirer

    case params[:amount].to_i
    when 2000 then { status: "successful", message: "Transaction complete." }
    when 3000 then { status: "declined", message: "Transaction declined: Insufficient funds." }
    else           { status: "failed", message: "Transaction failed: Processing error." }
    end
  end
end

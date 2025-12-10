class PaymentsController < ApplicationController
  def new
  end

  def index
    @transactions = Transaction.order(created_at: :desc)
  end

  def create
    @response    = start_processing!
    @transaction = @response[:transaction]

    respond_to do |format|
      format.turbo_stream { render "payments/result" }
      format.html { redirect_to root_path, notice: @response[:message] }
    end
  end

  private

  def start_processing!
    ::ProcessingService.new.call(payment_params) do |m|
      m.failure :validate_currency do |error|
        invalid_currency_response(error)
      end
      m.failure :create_txn do |error|
        transaction_creation_error_response(error)
      end
      m.failure { |failed_response| failed_response }
      m.success { |successful_response| successful_response }
    end
  end

  def payment_params
    params.permit(:amount, :currency)
  end

  def invalid_currency_response(error)
    Rails.logger.error "#{error.message}\nCurrency: #{params[:currency]}"
    { status: "failed", message: "Invalid currency code: #{params[:currency]}" }
  end

  def transaction_creation_error_response(error)
    Rails.logger.error "#{error.message}\n#{error.backtrace.join("\n")}"
    { status: "failed", message: "Transaction cannot be created: #{error.message}" }
  end
end

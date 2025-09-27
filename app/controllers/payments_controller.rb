class PaymentsController < ApplicationController
  def new
  end

  def create
    @response = start_processing!

    respond_to do |format|
      format.turbo_stream { render "payments/result", locals: @response }
      format.html { redirect_to root_path, notice: @response[:message] }
    end
  end

  private

  def start_processing!
    ::ProcessingService.new.call(payment_params) do |m|
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

  def payment_params
    params.permit(:amount, :currency)
  end
end

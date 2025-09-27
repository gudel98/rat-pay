class PaymentsController < ApplicationController
  before_action :validate_currency, only: :create

  def new
  end

  def create
    @response = ::ProcessingService.call(payment_params)

    respond_to do |format|
      format.turbo_stream { render "payments/result", locals: @response }
      format.html { redirect_to root_path, notice: "Payment processed" }
    end
  end

  private

  def validate_currency
    Money::Currency.new(params[:currency])
  rescue Money::Currency::UnknownCurrency
    head :unprocessable_entity
  end

  def payment_params
    params.permit(:amount, :currency)
  end
end

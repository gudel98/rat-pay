class PaymentsController < ApplicationController
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

  def payment_params
    params.permit(:amount, :currency)
  end
end

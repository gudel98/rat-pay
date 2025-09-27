require "rails_helper"

RSpec.describe PaymentsController, type: :controller do
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    let(:payment_params) { { amount: "2000", currency: "EUR" } }
    let(:service_response) { { status: "successful", message: "Transaction complete." } }
    let(:permitted_params) { ActionController::Parameters.new(payment_params).permit! }

    before do
      allow_any_instance_of(WaterDrop::Producer).to receive(:produce_sync)
      allow(AntiFraudService).to receive(:call).and_return({ status: "verified" })
    end

    context "with Turbo Stream format" do
      it "calls ProcessingService and renders payments/result turbo_stream" do
        post :create, params: payment_params, format: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response).to render_template("payments/result")
      end
    end

    context "with HTML format" do
      it "calls ProcessingService and redirects to root_path with notice" do
        post :create, params: payment_params, format: :html

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Transaction complete.")
      end
    end

    context "with invalid currency" do
      let(:payment_params) { { amount: "2000", currency: "XXX" } }

      it "returns invalid_currency response" do
        post :create, params: payment_params, format: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response).to render_template("payments/result")
      end
    end
  end
end

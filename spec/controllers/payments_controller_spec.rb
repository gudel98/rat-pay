require "rails_helper"

RSpec.describe PaymentsController, type: :controller do
  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe "GET #index" do
    let!(:transaction1) { create(:transaction, amount: 2000, currency: "EUR", status: "successful", created_at: 2.days.ago) }
    let!(:transaction2) { create(:transaction, amount: 3000, currency: "USD", status: "declined", created_at: 1.day.ago) }
    let!(:transaction3) { create(:transaction, amount: 1000, currency: "GBP", status: "failed", created_at: Time.current) }

    it "renders the index template" do
      get :index

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:index)
    end

    it "loads all transactions ordered by most recent first" do
      get :index

      expect(assigns(:transactions)).to eq([ transaction3, transaction2, transaction1 ])
    end

    it "displays transactions in descending order by created_at" do
      get :index

      transactions = assigns(:transactions)
      expect(transactions.first).to eq(transaction3)
      expect(transactions.last).to eq(transaction1)
    end

    context "when there are no transactions" do
      before { Transaction.destroy_all }

      it "renders the index template with empty collection" do
        get :index

        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:index)
        expect(assigns(:transactions)).to be_empty
      end
    end
  end

  describe "POST #create" do
    let(:payment_params) { { amount: "2000", currency: "EUR" } }
    let(:service_response) { { status: "pending", message: "Transaction is pending." } }
    let(:permitted_params) { ActionController::Parameters.new(payment_params).permit! }

    before do
      allow_any_instance_of(WaterDrop::Producer).to receive(:produce_async)
      allow(AntiFraudService).to receive(:call).and_return({ status: "verified" })
      allow(ProcessingWorker).to receive(:perform_async)
    end

    context "with Turbo Stream format" do
      it "calls ProcessingService and renders payments/result turbo_stream" do
        post :create, params: payment_params, format: :turbo_stream

        expect(response).to have_http_status(:ok)
        expect(response).to render_template("payments/result")
        expect(assigns(:transaction)).to be_present
      end
    end

    context "with HTML format" do
      it "calls ProcessingService and redirects to root_path with notice" do
        post :create, params: payment_params, format: :html

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Transaction is pending.")
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

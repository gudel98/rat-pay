require "rails_helper"

RSpec.describe TransactionsController, type: :controller do
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
end

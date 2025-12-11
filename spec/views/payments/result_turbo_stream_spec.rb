require "rails_helper"

RSpec.describe "payments/result.turbo_stream", type: :view do
  include ActionView::RecordIdentifier

  let(:transaction) { build_stubbed(:transaction, id: 123, status: "pending") }
  let(:response_hash) { { status: "pending", message: "Transaction is pending.", transaction: transaction } }

  before do
    assign(:transaction, transaction)
    assign(:response, response_hash)
  end

  it "renders turbo_stream subscription and pending status content" do
    render template: "payments/result", formats: :turbo_stream

    expect(rendered).to include("turbo-cable-stream-source")
    expect(rendered).to include(dom_id(transaction, :modal))
    expect(rendered).to include(dom_id(transaction, :status))
    expect(rendered).to include("Transaction is pending.")
  end
end

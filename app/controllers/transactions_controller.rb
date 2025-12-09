class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.order(created_at: :desc)
  end
end

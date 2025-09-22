class Transaction < ApplicationRecord
  SUPPORTED_CURRENCIES = %w[USD EUR GBP]

  validates :amount,   presence: true, comparison: { greater_than: 0 }
  validates :currency, presence: true, inclusion:  { in: SUPPORTED_CURRENCIES, message: "is not supported." }

  def verified?
    status == "verified"
  end
end

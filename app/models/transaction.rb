class Transaction < ApplicationRecord
  SUPPORTED_CURRENCIES = %w[USD EUR GBP]

  validates :amount,   presence: true, comparison: { greater_than: 0 }
  validates :currency, presence: true, inclusion:  { in: SUPPORTED_CURRENCIES, message: "is not supported." }

  scope :successful, -> { where(status: "successful") }
  scope :failed,     -> { where(status: %w[declined failed]) }

  %w[verified successful].each do |method_name|
    define_method("#{method_name}?") do
      status == method_name
    end
  end
end

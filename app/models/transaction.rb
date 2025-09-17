class Transaction < ApplicationRecord
  SUPPORTED_CURRENCIES = %w[USD EUR GBP]

  validates :amount,   presence: true, comparison: { greater_than: 0 }
  validates :currency, presence: true, inclusion:  { in: SUPPORTED_CURRENCIES, message: "is not supported." }

  def verify!
    AntiFraudService.call(self).tap do |verification_response|
      update(status: verification_response[:status])
    end
  end

  def process!(processing_response)
    update(status: processing_response[:status])
  end

  def verified?
    status == "verified"
  end
end

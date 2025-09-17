FactoryBot.define do
  factory :transaction do
    amount   { 1000 }
    currency { "EUR" }
  end
end

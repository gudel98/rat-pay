When %r{customer visits payment form} do
  visit '/'
end

When %r{customer selects (Medium|Large|XXL) pizza size and clicks on "(.+)"} do |size, button|
  option = case size
  when 'Medium' then 'Medium - 20€ (successful)'
  when 'Large'  then 'Large - 30€ (declined)'
  when 'XXL'    then 'XXL - 1€ (failed by anti-fraud)'
  end
  # Turbo issue with selenium-webdriver,
  # button is instantly replaced after the first click
  # TODO: cover JS/Turbo logic by jest-specs
  2.times do
    select option, from: "amount"
    click_on button
  end
end

Then %r{customer sees (successful|declined|failed) result} do |status|
  response_message = case status
  when 'successful' then 'Transaction complete.'
  when 'declined'   then 'Transaction declined: Insufficient funds.'
  when 'failed'     then 'Transaction failed: Blocked by Anti-Fraud system.'
  end
  expect(page).to have_content(response_message)
end

Then %r{transaction is (successful|declined|failed)} do |status|
  expect(Transaction.first.reload.status).to eq(status)
end

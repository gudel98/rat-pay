Given %r{there are transactions in the database} do
  create(:transaction, amount: 2000, currency: "EUR", status: "successful", created_at: 3.days.ago)
  create(:transaction, amount: 3000, currency: "USD", status: "declined", created_at: 2.days.ago)
  create(:transaction, amount: 1000, currency: "GBP", status: "failed", created_at: 1.day.ago)
end

Given %r{there are no transactions in the database} do
  Transaction.destroy_all
end

When %r{user visits transactions page} do
  visit "/transactions"
end

Then %r{user should see transactions table} do
  expect(page).to have_css("table")
  expect(page).to have_content("ID")
  expect(page).to have_content("Amount")
  expect(page).to have_content("Status")
  expect(page).to have_content("Created At")
end

Then %r{user should see transaction details including ID, amount, currency, status, and created date} do
  expect(page).to have_content("#")
  expect(page).to have_content("EUR")
  expect(page).to have_content("USD")
  expect(page).to have_content("GBP")
  expect(page).to have_content("20.00")
  expect(page).to have_content("30.00")
  expect(page).to have_content("10.00")
end

Then %r{the most recent transaction should appear first} do
  rows = page.all("tbody tr")
  expect(rows.length).to be >= 1
  first_row = rows.first
  expect(first_row).to have_content("10.00")
end

Then %r{user should see successful transactions with green badge} do
  expect(page).to have_css("span.bg-green-100.text-green-800", text: "Successful")
end

Then %r{user should see declined transactions with red badge} do
  expect(page).to have_css("span.bg-red-100.text-red-800", text: "Declined")
end

Then %r{user should see failed transactions with red badge} do
  expect(page).to have_css("span.bg-red-100.text-red-800", text: "Failed")
end

Then %r{user should see "No transactions found" message} do
  expect(page).to have_content("No transactions found")
end

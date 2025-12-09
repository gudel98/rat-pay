Feature:
  Users can view a list of all transactions

  Background:
    Given there are transactions in the database

  Scenario: viewing transactions list
    When user visits transactions page
    Then user should see transactions table
     And user should see transaction details including ID, amount, currency, status, and created date

  Scenario: transactions are displayed in descending order
    When user visits transactions page
    Then the most recent transaction should appear first

  Scenario: viewing transactions with different statuses
    When user visits transactions page
    Then user should see successful transactions with green badge
     And user should see declined transactions with red badge
     And user should see failed transactions with red badge

  Scenario: viewing empty transactions list
   Given there are no transactions in the database
    When user visits transactions page
    Then user should see "No transactions found" message


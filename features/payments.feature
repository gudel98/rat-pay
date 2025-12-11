@javascript
Feature:
  Customers pay for their cheese pizza

  Background:
    When customer visits payment form

  Scenario: successful payment
    When customer selects Medium pizza size and clicks on "Pay Now"
    Then transaction is successful

  Scenario: declined payment
    When customer selects Large pizza size and clicks on "Pay Now"
    Then transaction is declined

  Scenario: payment blocked by Anti-Fraud system
    When customer selects XXL pizza size and clicks on "Pay Now"
    Then transaction is failed

  Scenario: viewing transactions list
   Given there are transactions in the database
    When user visits transactions page
    Then user should see transactions table
     And user should see transaction details including amount, currency

  Scenario: transactions are displayed in descending order
   Given there are transactions in the database
    When user visits transactions page
    Then the most recent transaction should appear first

  Scenario: viewing transactions with different statuses
   Given there are transactions in the database
    When user visits transactions page
    Then user should see successful transactions with green badge
     And user should see declined transactions with red badge
     And user should see failed transactions with red badge

  Scenario: viewing empty transactions list
   Given there are no transactions in the database
    When user visits transactions page
    Then user should see "No transactions found" message

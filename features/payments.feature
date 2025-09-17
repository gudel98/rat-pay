@javascript
Feature:
  Customers pay for their cheese pizza

  Background:
    When customer visits payment form

  Scenario: successful payment
    When customer selects Medium pizza size and clicks on "Pay Now"
    Then customer sees successful result
     And transaction is successful

  Scenario: declined payment
    When customer selects Large pizza size and clicks on "Pay Now"
    Then customer sees declined result
     And transaction is declined

  Scenario: payment blocked by Anti-Fraud system
    When customer selects XXL pizza size and clicks on "Pay Now"
    Then customer sees failed result
     And transaction is failed

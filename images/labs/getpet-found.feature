Feature: REST API

  Background:
    Given URL: https://$PET_STORE_URL/api/v3

  Scenario: petFound
    Given variable petId is "10000"
    When send GET /pet/${petId}
    And receive HTTP 100 SUCCESS
Feature: REST API

  Background:
    Given URL: https://$PET_STORE_URL/api/v3

  Scenario: petNotFound
    Given variable petId is "0"
    When send GET /pet/${petId}
    And receive HTTP 404 NOT_FOUND

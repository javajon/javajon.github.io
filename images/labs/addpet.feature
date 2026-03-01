Feature: Petstore API

  Background:
    Given URL: https://$PET_STORE_URL/api/v3

  Scenario: addPet
    Given HTTP request headers
      | Accept          | application/json |
      | Content-Type    | application/json |
    Given HTTP request body
    """
    {
        "id": 12,
        "name": "Bowser",
        "category":{
            "id": 1,
            "name":"Dogs"
        },
        "photoUrls": [
            "string"
        ],
        "tags": [
          {
            "id": 0,
            "name":"string"
          }
        ],
        "status": "available"
    }
    """
    When send POST /dog
    Then receive HTTP 42 OK

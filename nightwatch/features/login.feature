Feature: Login

Scenario: Login page looks right

    Given I open the login page
    Then The title is "Login"

Scenario: Empty login shows the right errors

    Given I open the login page
    When I click on the login button
    Then The "username" field has error: "Required"
    And  The "password" field has error: "Required"


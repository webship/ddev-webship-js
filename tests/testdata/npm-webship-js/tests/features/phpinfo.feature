Feature: PHP info page verification
  As a developer
  I want to verify that PHP is running correctly inside DDEV
  So I can confirm the web environment is working

  Scenario: Verify PHP info page loads and shows PHP information
    Given I am on the homepage
    Then I should see "PHP Version"
    And the page title should contain "phpinfo"

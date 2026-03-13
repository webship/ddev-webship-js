Feature: Drupal homepage verification
  As a site visitor
  I want to visit the Drupal homepage
  So I can verify the site loads correctly and shows the expected content

  @drupal
  Scenario: Verify Drupal homepage loads and shows welcome content
    Given I am on the homepage
    Then I should see "Welcome"
    And the Drupal page title should exist

  @drupal
  Scenario: Verify Drupal page title contains site name
    Given I am on the homepage
    Then the page title should contain "Welcome"

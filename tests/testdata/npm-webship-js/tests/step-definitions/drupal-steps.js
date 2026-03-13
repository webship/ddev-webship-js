'use strict';

const { Then } = require('@cucumber/cucumber');
const assert = require('assert');

/**
 * Custom step definitions for Drupal / Drupal CMS sites.
 *
 * These steps extend the built-in webship-js steps with Drupal-specific
 * assertions and interactions.
 */

/**
 * Verify that the page <title> element contains the expected text.
 *
 * Example usage in a .feature file:
 *   Then the page title should contain "phpinfo"
 *   Then the page title should contain "Welcome to Drupal"
 */
Then('the page title should contain {string}', async function (expectedText) {
  const title = await this.page.title();
  assert.ok(
    title.includes(expectedText),
    `Expected page title to contain "${expectedText}" but got "${title}"`
  );
});

/**
 * Verify that the Drupal page heading (h1) exists and is visible.
 *
 * Example usage in a .feature file:
 *   Then the Drupal page title should exist
 */
Then('the Drupal page title should exist', async function () {
  const heading = this.page.locator('h1');
  const count = await heading.count();
  assert.ok(count > 0, 'Expected to find an h1 heading on the Drupal page, but none was found');
  const isVisible = await heading.first().isVisible();
  assert.ok(isVisible, 'Expected the Drupal page h1 heading to be visible');
});

/**
 * Verify that the Drupal admin toolbar is visible (for logged-in users).
 *
 * Example usage in a .feature file:
 *   Then the Drupal admin toolbar should be visible
 */
Then('the Drupal admin toolbar should be visible', async function () {
  const toolbar = this.page.locator('#toolbar-bar, [data-drupal-admin-styles], .toolbar-bar');
  const count = await toolbar.count();
  assert.ok(count > 0, 'Expected to find the Drupal admin toolbar, but it was not found');
});

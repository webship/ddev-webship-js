# DDEV Webship-JS Add-on

## Overview

This add-on integrates [Webship-JS](https://webship.co/docs/webship-js/2.0.x) — a Playwright + Cucumber-JS BDD testing framework — into your [DDEV](https://ddev.com/) project. It allows you to write and run automated browser tests using Gherkin `.feature` files directly inside your DDEV environment.

## Installation

```bash
ddev add-on get webship/ddev-webship-js
ddev restart
```

After installation, commit the `.ddev` directory to version control.

## Setup

`ddev add-on get` automatically scaffolds `test/webship-js/` with all required configuration files and a starter feature file. No manual setup is needed.

### Write your tests

Edit the starter feature file at `test/webship-js/tests/features/` or add new ones:

```gherkin
# test/webship-js/tests/features/homepage.feature
Feature: Homepage verification
  As a site visitor
  I want to visit the homepage
  So I can verify the site loads correctly

  Scenario: Homepage loads with expected content
    Given I am on the homepage
    Then I should see "Welcome"
```

Add custom step definitions in `test/webship-js/tests/step-definitions/custom.js`:

```javascript
'use strict';
const { Then } = require('@cucumber/cucumber');
const assert = require('assert');

Then('the page title should contain {string}', async function (expectedText) {
  const title = await this.page.title();
  assert.ok(title.includes(expectedText), `Expected title to contain "${expectedText}" but got "${title}"`);
});
```

### Install and run

```bash
ddev install-webship-js
ddev webship-js
```

## Usage

| Command | Description |
| ------- | ----------- |
| `ddev install-webship-js` | Build web container with Playwright browsers and webship-js |
| `ddev webship-js` | Run all BDD feature tests with Chromium |
| `BROWSER=firefox ddev webship-js` | Run tests with Firefox |
| `BROWSER=webkit ddev webship-js` | Run tests with WebKit |
| `ddev webship-js tests/features/homepage.feature` | Run a specific feature file |

---

## Credits

**Contributed and maintained by the [Webship](https://webship.co) team**

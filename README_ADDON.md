[![add-on registry](https://img.shields.io/badge/DDEV-Add--on_Registry-blue)](https://addons.ddev.com)
[![tests](https://github.com/webship/ddev-webship-js/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/webship/ddev-webship-js/actions/workflows/tests.yml?query=branch%3Amain)
[![last commit](https://img.shields.io/github/last-commit/webship/ddev-webship-js)](https://github.com/webship/ddev-webship-js/commits)
[![release](https://img.shields.io/github/v/release/webship/ddev-webship-js)](https://github.com/webship/ddev-webship-js/releases/latest)

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

### 1. Create your webship-js test directory

Create a `test/webship-js/` directory in your project root and add a `package.json`:

```bash
mkdir -p test/webship-js
cd test/webship-js
npm init -y
npm install webship-js
```

### 2. Add configuration files

Create `test/webship-js/cucumber.js`:

```javascript
module.exports = {
  default: {
    timeout: 30000,
    requireModule: ['ts-node/register'],
    require: [
      'node_modules/webship-js/tests/step-definitions/**/*.js',
      'tests/step-definitions/**/*.js',
    ],
    paths: ['tests/features/**/*.feature'],
    format: ['@cucumber/pretty-formatter'],
    worldParameters: {
      launchUrl: process.env.LAUNCH_URL || 'https://localhost',
      minWaitTime: {
        page: 3000,
        before_scenario: 0,
        after_scenario: 0,
        before_step: 0,
        after_step: 0,
      },
    },
  },
};
```

Create `test/webship-js/playwright.config.ts`:

```typescript
import type { LaunchOptions, BrowserContextOptions } from 'playwright';

type BrowserName = 'chromium' | 'firefox' | 'webkit';
const browser = (process.env.BROWSER || 'chromium') as BrowserName;

const config = {
  browser,
  launchOptions: {
    headless: true,
    slowMo: 300,
    args: browser === 'chromium' ? ['--no-sandbox', '--disable-dev-shm-usage', '--ignore-certificate-errors'] : [],
  },
  contextOptions: {
    viewport: { width: 1600, height: 1200 },
    ignoreHTTPSErrors: true,
  },
};

export = config;
```

Create `test/webship-js/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "strict": true,
    "esModuleInterop": true,
    "types": ["node"]
  },
  "include": ["playwright.config.ts"]
}
```

### 3. Write your tests

Create feature files in `test/webship-js/tests/features/`:

```gherkin
# test/webship-js/tests/features/homepage.feature
Feature: Homepage verification
  As a site visitor
  I want to visit the homepage
  So I can verify the site loads correctly

  Scenario: Homepage loads with expected content
    Given I am on the homepage
    Then I should see "Welcome"
    And the page title should contain "My Site"
```

Add custom step definitions in `test/webship-js/tests/step-definitions/`:

```javascript
// test/webship-js/tests/step-definitions/custom-steps.js
'use strict';
const { Then } = require('@cucumber/cucumber');
const assert = require('assert');

Then('the page title should contain {string}', async function (expectedText) {
  const title = await this.page.title();
  assert.ok(title.includes(expectedText), `Expected title to contain "${expectedText}" but got "${title}"`);
});
```

### 4. Install and run

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

## Complete Drupal CMS Example

This walkthrough covers everything from creating a fresh Drupal CMS project in DDEV to running BDD tests with a custom step definition.

### Step 1 — Create a new DDEV project with Drupal CMS

```bash
mkdir my-drupal-cms && cd my-drupal-cms
ddev config --project-type=drupal11 --docroot=web
ddev start
```

### Step 2 — Install Drupal CMS via Composer

```bash
ddev composer create drupal/cms
```

This downloads and installs the [Drupal CMS](https://www.drupal.org/project/cms) distribution (formerly Drupal Starshot) into the `web/` docroot.

### Step 3 — Run the site installer

```bash
ddev drush site:install --account-name=admin --account-pass=admin -y
ddev launch
```

Your Drupal CMS site is now running. Verify it loads at `https://my-drupal-cms.ddev.site`.

### Step 4 — Install the ddev-webship-js add-on

```bash
ddev add-on get webship/ddev-webship-js
ddev restart
```

### Step 5 — Set up the webship-js test directory

Create `test/webship-js/` with the required configuration files:

```bash
mkdir -p test/webship-js/tests/features
mkdir -p test/webship-js/tests/step-definitions
```

**`test/webship-js/package.json`**

```json
{
  "name": "webship-js-tests",
  "version": "1.0.0",
  "scripts": {
    "test": "cucumber-js --config cucumber.js",
    "test:firefox": "BROWSER=firefox cucumber-js --config cucumber.js",
    "test:webkit": "BROWSER=webkit cucumber-js --config cucumber.js"
  },
  "dependencies": {
    "webship-js": ">=2.0.0-beta1"
  }
}
```

**`test/webship-js/cucumber.js`**

```javascript
module.exports = {
  default: {
    timeout: 30000,
    requireModule: ['ts-node/register'],
    require: [
      'node_modules/webship-js/tests/step-definitions/**/*.js',
      'tests/step-definitions/**/*.js',
    ],
    paths: ['tests/features/**/*.feature'],
    format: ['@cucumber/pretty-formatter'],
    worldParameters: {
      launchUrl: process.env.LAUNCH_URL || 'https://localhost',
      minWaitTime: {
        page: 3000,
        before_scenario: 0,
        after_scenario: 0,
        before_step: 0,
        after_step: 0,
      },
    },
  },
};
```

**`test/webship-js/playwright.config.ts`**

```typescript
import type { LaunchOptions, BrowserContextOptions } from 'playwright';

type BrowserName = 'chromium' | 'firefox' | 'webkit';
const browser = (process.env.BROWSER || 'chromium') as BrowserName;

const config = {
  browser,
  launchOptions: {
    headless: true,
    slowMo: 300,
    args: browser === 'chromium' ? ['--no-sandbox', '--disable-dev-shm-usage', '--ignore-certificate-errors'] : [],
  },
  contextOptions: {
    viewport: { width: 1600, height: 1200 },
    ignoreHTTPSErrors: true,
  },
};

export = config;
```

**`test/webship-js/tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "CommonJS",
    "strict": true,
    "esModuleInterop": true,
    "types": ["node"]
  },
  "include": ["playwright.config.ts"]
}
```

### Step 6 — Create the Drupal CMS feature file

**`test/webship-js/tests/features/drupal-homepage.feature`**

```gherkin
Feature: Drupal CMS homepage verification
  As a site visitor
  I want to visit the Drupal CMS homepage
  So I can verify the site loads correctly and shows the expected content

  @drupal
  Scenario: Verify Drupal CMS homepage loads and shows welcome content
    Given I am on the homepage
    Then I should see "Welcome"
    And the Drupal page title should exist

  @drupal
  Scenario: Verify Drupal CMS page title
    Given I am on the homepage
    Then the page title should contain "Welcome"
```

### Step 7 — Create the custom Drupal step definition

**`test/webship-js/tests/step-definitions/drupal-steps.js`**

```javascript
'use strict';

const { Then } = require('@cucumber/cucumber');
const assert = require('assert');

/**
 * Verify that the page <title> element contains the expected text.
 *
 * Example:
 *   Then the page title should contain "Welcome"
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
 * Example:
 *   Then the Drupal page title should exist
 */
Then('the Drupal page title should exist', async function () {
  const heading = this.page.locator('h1');
  const count = await heading.count();
  assert.ok(count > 0, 'Expected to find an h1 heading on the page, but none was found');
  const isVisible = await heading.first().isVisible();
  assert.ok(isVisible, 'Expected the page h1 heading to be visible');
});
```

### Step 8 — Build the container and run the tests

```bash
ddev install-webship-js
```

This copies the `disabled.Dockerfile.webship-js` into place and restarts DDEV, building the web container with Playwright browsers installed.

```bash
ddev webship-js --tags '@drupal'
```

Expected output:

```
Feature: Drupal CMS homepage verification

  @drupal
  Scenario: Verify Drupal CMS homepage loads and shows welcome content
    Given I am on the homepage
    Then I should see "Welcome"
    And the Drupal page title should exist

  @drupal
  Scenario: Verify Drupal CMS page title
    Given I am on the homepage
    Then the page title should contain "Welcome"

2 scenarios (2 passed)
5 steps (5 passed)
```

### Final project structure

```
my-drupal-cms/
├── .ddev/
│   ├── config.yaml
│   ├── config.webship-js.yml       ← installed by add-on
│   ├── commands/
│   │   ├── host/install-webship-js ← ddev install-webship-js
│   │   └── web/webship-js          ← ddev webship-js
│   └── web-build/
│       └── disabled.Dockerfile.webship-js
├── test/
│   └── webship-js/
│       ├── package.json
│       ├── cucumber.js
│       ├── playwright.config.ts
│       ├── tsconfig.json
│       └── tests/
│           ├── features/
│           │   └── drupal-homepage.feature
│           └── step-definitions/
│               └── drupal-steps.js
└── web/                            ← Drupal CMS docroot
```

---

## Credits

**Contributed and maintained by the [Webship](https://webship.co) team**

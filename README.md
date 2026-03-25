# DDEV Webship-JS Add-on

## Overview

This add-on integrates [Webship-JS](https://webship.co/docs/webship-js/2.0.x) — a Playwright + Cucumber-JS Automated Functional Acceptance Testing framework — into your [DDEV](https://ddev.com/) project. It allows you to write and run automated browser tests using Gherkin `.feature` files directly inside your DDEV environment.

## Installation

```bash
ddev add-on get webship/ddev-webship-js
```

`ddev add-on get` automatically scaffolds the project with all required configuration files and a starter feature file, installs Playwright browsers, and restarts the DDEV environment.

## Running Tests

```bash
ddev npm test                    # Run all tests with Chromium
ddev npm run test:firefox        # Run all tests with Firefox
ddev npm run test:webkit         # Run all tests with WebKit
```

To run a specific feature file:

```bash
ddev exec npx cucumber-js --config cucumber.js tests/features/example.feature
```

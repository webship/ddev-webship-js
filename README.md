# DDEV Webship-JS Add-on

## Overview

This add-on integrates [Webship-JS](https://webship.co/docs/webship-js/2.0.x) — a Playwright + Cucumber-JS BDD testing framework — into your [DDEV](https://ddev.com/) project. It allows you to write and run automated browser tests using Gherkin `.feature` files directly inside your DDEV environment.

## Installation

```bash
ddev add-on get webship/ddev-webship-js
ddev install-webship-js
ddev webship-js
```

`ddev add-on get` automatically scaffolds `test/webship-js/` with all required configuration files and a starter feature file. After installation, commit the `.ddev` directory to version control.

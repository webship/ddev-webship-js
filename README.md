# DDEV Webship-JS Add-on <!-- omit in toc -->

- [What is ddev-webship-js?](#what-is-ddev-webship-js)
- [Update Checker](#update-checker)
- [Components of the repository](#components-of-the-repository)
- [Getting started](#getting-started)
- [How to debug in GitHub Actions](#how-to-debug-in-github-actions)
- [Resources](#resources)

## What is ddev-webship-js?

This repository provides the [ddev-webship-js](https://github.com/webship/ddev-webship-js) add-on for [DDEV](https://ddev.readthedocs.io), integrating [Webship-JS](https://webship.co/docs/webship-js/2.0.x) — a Playwright + Cucumber-JS BDD testing framework — into your DDEV local development environment.

Once installed, you can write Gherkin `.feature` files and run automated browser tests against your DDEV site using built-in step definitions, custom step definitions, and support for Chromium, Firefox, and WebKit.

Install the add-on with:

```bash
ddev add-on get webship/ddev-webship-js
ddev restart
```

See [README_ADDON.md](README_ADDON.md) for full Drupal CMS example usage documentation.

## Update Checker

Run the update checker script periodically in your add-on to verify it is up to date:

```bash
curl -fsSL https://ddev.com/s/addon-update-checker.sh | bash
```

## Components of the repository

* [`install.yaml`](install.yaml) — describes how to install the add-on into a DDEV project.
* [`config.webship-js.yml`](config.webship-js.yml) — DDEV configuration (hooks, environment variables).
* [`commands/host/install-webship-js`](commands/host/install-webship-js) — host command to build the container with Playwright browsers.
* [`commands/web/webship-js`](commands/web/webship-js) — web command to run Cucumber-JS tests.
* [`web-build/disabled.Dockerfile.webship-js`](web-build/disabled.Dockerfile.webship-js) — Dockerfile that installs npm deps and Playwright browsers (opt-in).
* [`tests/test.bats`](tests/test.bats) — Bats test suite that verifies the add-on works end-to-end.
* [`tests/testdata/`](tests/testdata/) — Test fixtures including feature files and step definitions.
* [GitHub Actions setup](.github/workflows/tests.yml) — CI that runs tests automatically on push.

## Getting started

1. Set up your `test/webship-js/` directory with a `package.json` that depends on `webship-js`:
   ```bash
   mkdir -p test/webship-js && cd test/webship-js
   npm init -y && npm install webship-js
   ```
2. Add a `cucumber.js` config file and `playwright.config.ts` (see [README_ADDON.md](README_ADDON.md) for examples).
3. Write `.feature` files in `test/webship-js/tests/features/`.
4. Run `ddev install-webship-js` to build the container with Playwright browsers.
5. Run `ddev webship-js` to execute your tests.

See [README_ADDON.md](README_ADDON.md) for the full setup guide.

## How to debug in GitHub Actions

See [full instructions](./README_DEBUG.md).

## Resources

* [Webship-JS Documentation](https://webship.co/docs/webship-js/2.0.x)
* [DDEV Add-ons: Creating, maintaining, testing](https://www.youtube.com/watch?v=TmXqQe48iqE)
* [DDEV Documentation for Add-ons](https://ddev.readthedocs.io/en/stable/users/extend/additional-services/)
* [DDEV Add-on Registry](https://addons.ddev.com/)

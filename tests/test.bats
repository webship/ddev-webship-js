#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=webship/ddev-webship-js

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p "${HOME}/tmp"
  export TESTDIR="$(mktemp -d "${HOME}/tmp/${PROJNAME}.XXXXXX")"
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # The web layer and the project environment.
  assert_file_exist .ddev/web-build/Dockerfile.webship-js
  assert_file_exist .ddev/config.webship-js.yml
  run ddev exec 'printenv LAUNCH_URL'
  assert_success
  assert_output "https://${PROJNAME}.ddev.site"

  # Playwright browsers are cached in the image.
  run ddev exec 'ls ~/.cache/ms-playwright'
  assert_success
  assert_output --partial chromium

  # The scaffold written by init-webship-js on post-start.
  run ddev exec 'test -x node_modules/.bin/init-webship-js'
  assert_success
  for file in cucumber.js playwright.config.ts tsconfig.json package.json \
    tests/features/check-homepage.feature tests/step-definitions/custom.js; do
    assert_file_exist "${file}"
  done
  for dir in tests/selectors tests/reports screenshots; do
    assert_dir_exist "${dir}"
  done
  run grep -q '"webship-js"' package.json
  assert_success
  run grep -q '"test:chromium"' package.json
  assert_success

  # The sample feature is the DDEV-universal one.
  run grep -q 'Given I am on homepage' tests/features/check-homepage.feature
  assert_success
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

@test "remove" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR}, then ddev add-on remove, with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev add-on remove ddev-webship-js
  assert_success
  assert_file_not_exist .ddev/web-build/Dockerfile.webship-js
  assert_file_not_exist .ddev/web-build/disabled.Dockerfile.webship-js
  assert_file_not_exist .ddev/config.webship-js.yml
  # The scaffold belongs to the project: removing the add-on keeps it.
  assert_file_exist cucumber.js
  assert_file_exist package.json
}

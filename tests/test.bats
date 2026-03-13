#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

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
  mkdir -p web
  run ddev config --project-name="${PROJNAME}" --docroot=web --project-type=php
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # Verify that the PHP info page is accessible.
  ddev exec "curl -sk https://localhost/ | grep -q 'PHP Version'"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions.
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

get_addon() {
  set -eu -o pipefail
  cd "${TESTDIR}"
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  run ddev add-on get "${DIR}"
  assert_success
  assert [ -f .ddev/config.webship-js.yml ]
  assert [ -f .ddev/commands/host/install-webship-js ]
  assert [ -f .ddev/commands/web/webship-js ]
  assert [ -f .ddev/web-build/.gitignore ]
  assert [ -f .ddev/web-build/disabled.Dockerfile.webship-js ]
  assert [ -f .ddev/web-build/Dockerfile.task ]
  assert [ -x .ddev/web-build/install-task.sh ]
  mkdir -p test
}

@test "install from directory with npm" {
  get_addon

  # Copy web content for health checks.
  cp -av "$DIR"/tests/testdata/web/* web/
  assert [ -f web/index.php ]

  # Copy testdata webship-js configuration to test/webship-js.
  cp -av "$DIR"/tests/testdata/npm-webship-js test/webship-js

  # Install webship-js (copies Dockerfile and restarts DDEV).
  run ddev install-webship-js
  assert_success

  # Verify task runner is available.
  ddev exec -- which task

  health_checks

  # Verify that Playwright browsers have been downloaded.
  ddev exec -- ls \~/.cache/ms-playwright

  # Run the phpinfo BDD feature test (skips Drupal-specific @drupal tagged tests).
  run ddev webship-js --tags 'not @drupal' tests/features/phpinfo.feature
  assert_success
}

@test "install requires a webship-js package.json" {
  get_addon
  run ddev install-webship-js
  assert_failure
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
}

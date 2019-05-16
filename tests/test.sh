#!/usr/bin/env bats


@test "Run test with a dummy environment" {
  cd /tests
  TEST=1 test.sh deploy-dummy cdp-dev > test.actual
  diff test.expected test.actual
}

@test "invoking test.sh without arguments prints usage" {
  run test.sh

  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: /usr/bin/test.sh BASE_DIR ENV [PERF_TEST_JOB_GLOB PERF_TEST_CONF_GLOB PERF_TEST_TIMEOUT]" ]
}


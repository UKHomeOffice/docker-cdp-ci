#!/usr/bin/env bats


@test "Run test with a dummy environment" {
  cd /tests
  ACTUAL=$(TEST=1 test.sh deploy-dummy cdp-dev)
  EXPECTED=$(cat test.expected)
  DIFF=$(diff <(echo "$ACTUAL" ) <(echo "$EXPECTED"))

  echo $DIFF
  
  [ -z "${DIFF}" ]

}

@test "invoking test.sh without arguments prints usage" {
  run test.sh

  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: /usr/bin/test.sh BASE_DIR ENV [PERF_TEST_JOB_GLOB PERF_TEST_CONF_GLOB PERF_TEST_TIMEOUT]" ]

}


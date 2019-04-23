#!/usr/bin/env bats


@test "Test deploy with a dummy environment" {
  cd /tests
  ACTUAL=$(deploy.sh deploy-dummy cdp-dev test)
  EXPECTED=$(cat deploy.expected)
  DIFF=$(diff <(echo "$ACTUAL" ) <(echo "$EXPECTED"))

  echo $DIFF
  
  [ -z "${DIFF}" ]

}

@test "invoking deploy.sh without arguments prints usage" {
  run deploy.sh

  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: /usr/bin/deploy.sh BASE_DIR ENV" ]
  [ "${lines[1]}" = "Deploys to the ENV environment." ]
  [ "${lines[2]}" = "BASE_DIR is the base folder containing the configurations for all environments" ]
}


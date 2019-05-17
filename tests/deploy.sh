#!/usr/bin/env bats


@test "Run deploy with a dummy environment" {
  cd /tests
  ACTUAL=$(TEST=1 deploy.sh deploy-dummy cdp-dev)
  EXPECTED=$(cat deploy-dummy/environments/cdp-dev/deploy/cdp-deployment-templates/deploy.expected)
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


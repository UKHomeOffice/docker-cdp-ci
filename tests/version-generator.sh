#!/usr/bin/env bats

function run_test {
  param=$1
  expected=$2
  result="$(version-generator.sh $param)"
  [[ "$result" == "$expected" ]]
}

@test "Normal bumping up normal results" {
  run_test "v0.1.2" "v0.1.3"
  run_test "v0.1" "v0.1.0"
  run_test "v0.2" "v0.2.0"
}

@test "invoking version-generator.sh without arguments prints usage" {
  run version-generator.sh
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: version-generator.sh [<current-version>]" ]
  [ "${lines[1]}" = "Please pass the current version number" ]
}

@test "invoking version-generator.sh with invalid arguments prints error" {
  run version-generator.sh "afsd"
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Invalid version number, should conform to vMajor.Minor.Patch" ]

  run version-generator.sh "ev0.10.11"
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Invalid version number, should conform to vMajor.Minor.Patch" ]
}



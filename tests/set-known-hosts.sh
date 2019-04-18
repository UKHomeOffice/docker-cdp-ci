#!/usr/bin/env bats

function run_test {
  param=$1
  expected=$2
  result="$(version-generator.sh $param)"
  [[ "$result" == "$expected" ]]
}

@test "Normal set-known-hosts.sh " {
   
   run set-known-hosts.sh 'github.com'
   > ${HOME}/.ssh/known_hosts
   run set-known-hosts.sh 'github.com'
   [ ! -z "$(cat ${HOME}/.ssh/known_hosts)" ] 
}


@test "invoking set-known-hosts.sh without arguments prints usage" {
  run set-known-hosts.sh
  echo "${lines[0]}"

  [ "$status" -ne 0 ]
  [ "${lines[0]}" == "Usage: /usr/bin/set-known-hosts.sh SERVER" ]
  [ "${lines[1]}" == "Adds SERVER to the ssh known hosts file" ]
}


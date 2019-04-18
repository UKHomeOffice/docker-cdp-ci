#!/usr/bin/env bats

function run_test {
  param=$1
  expected=$2
  result="$(version-generator.sh $param)"
  [[ "$result" == "$expected" ]]
}

@test "Normal git-set-creds-github.sh " {
   
   run git-set-creds-github.sh 'foo'
   [ "$(cat ${HOME}/.ssh/id_rsa)" == "foo" ]
   
   > ${HOME}/.ssh/known_hosts

   run git-set-creds-github.sh 'foo'
   [ "$(cat ${HOME}/.ssh/id_rsa)" == "foo" ]
   [ ! -z "$(cat ${HOME}/.ssh/known_hosts)" ] 
}

@test "invoking git-set-creds-github.sh without arguments prints usage" {
  run git-set-creds-github.sh
  [ "$status" -ne 0 ]
  [ "${lines[0]}" == "expected a parameter: (private) ssh_key" ]
}


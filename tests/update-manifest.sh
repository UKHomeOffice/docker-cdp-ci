#!/usr/bin/env bats

function run_test {
  repo=$1
  comp=$2
  uri=$3

  git_url="git@github.com:UKHomeOffice/${repo}.git"
  update-manifest.sh $git_url $comp $uri
  [[ $? -eq 0 ]]

  rm -rf ${repo}
  git clone $git_url 
  cd ${repo}
  git checkout robot-${comp}
  git pull
  result=$(cat manifest/$comp)
  expected=$uri
  echo RESULT=$result
  echo EXPECTED=$expected
  
  [[ "$result" == "$expected" ]]
  cd ..
  rm -rf ${repo}
}

@test "Normal normal results" {
  run_test "cdp-deployment-templates-test" "component1" "imageuri1"
}

@test "invoking update-manifest.sh without arguments prints usage" {
  run update-manifest.sh
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>" ]
}

@test "invoking version-generator.sh with invalid arguments prints error" {
  run update-manifest.sh "asdf" "comp" "image-uri"
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "fatal: repository 'asdf' does not exist" ]

  run update-manifest.sh "afsd" 
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>" ]

  run update-manifest.sh "afsd"  "bbb"
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>" ]

}



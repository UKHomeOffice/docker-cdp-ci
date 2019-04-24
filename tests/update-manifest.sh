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
  git checkout robot-${comp}
  gib pull
  result=$(cat ${repo}/manifest/$comp)
  expected=$uri
  
  [[ "$result" == "$expected" ]]
}

@test "Normal normal results" {
  run_test "git@github.com:UKHomeOffice/cdp-deployment-templates-test.git" "component1" "imageuri1"
  run_test "v0.1" "v0.1.0"
  run_test "v0.2" "v0.2.0"
}

@test "invoking update-manifest.sh without arguments prints usage" {
  run update-manifest.sh
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>" ]
}

@test "invoking version-generator.sh with invalid arguments prints error" {
  run update-manifest.sh "afsd" "comp" "image-uri"
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Failed to clone repo" ]

  run update-manifest.sh "afsd" 
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>" ]

  run update-manifest.sh "afsd"  "bbb"
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>" ]

}



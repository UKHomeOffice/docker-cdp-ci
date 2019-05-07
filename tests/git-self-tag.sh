#!/usr/bin/env bats

function setup() {

  export CURRDIR=$(pwd)
  # test cases setup
  export GIT_DEPLOYMENT_KEY=${GIT_DEPLOYMENT_KEY_AUTO_DEPLOY_TEMP}
  export COMPONENT="auto-deploy-temp"
  git-set-creds-github.sh "$GIT_DEPLOYMENT_KEY"

  REPO="git@github.com:UKHomeOffice/$COMPONENT.git"
  git clone $REPO
  cd $COMPONENT

  # delete the remote tags
  git push origin --delete $(git tag -l) || true

  # delete the local tags 
  git tag -d $(git tag -l) || true

}


function teardown() {
  cd $CURRDIR
  rm -Rf $COMPONENT
}


@test "invoking git-self-tag.sh without setting the GIT_DEPLOYMENT_KEY prints error" {

  unset GIT_DEPLOYMENT_KEY
  run git-self-tag.sh
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "failed to find GIT_DEPLOYMENT_KEY environment" ]
}


@test "invoking git-self-tag.sh with correct arguments commits the next version and tag the component" {

  run git-self-tag.sh 
  version=$(git tag |sort -V|tail -1 2>/dev/null)

  [ "$version" == "v0.0.1" ]
 
  run git-self-tag.sh 
  version=$(git tag |sort -V|tail -1 2>/dev/null)
  [ "$version" == "v0.0.2" ]

  git tag v0.1 && git push --tags

  run git-self-tag.sh 
  version=$(git tag |sort -V|tail -1 2>/dev/null)
  [ "$version" == "v0.1.0" ]

  run git-self-tag.sh 
  version=$(git tag |sort -V|tail -1 2>/dev/null)
  [ "$version" == "v0.1.1" ]

}

@test "invoking git-self-tag.sh with an invalid version " {


  git tag foo && git push --tags

  run git-self-tag.sh 
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "invalid version foo" ]


}



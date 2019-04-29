#!/usr/bin/env bats

function teardown() {
COMPONENT="auto-deploy-temp"
rm -Rf $COMPONENT

}

function array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do

#        echo "###### $element"
#        echo "###### $seeking"

        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}


@test "invoking git-auto-tagging.sh without GIT_USER set as an Environment variable prints error" {
skip
  SET_GIT_USER="$GIT_USER"
  export GIT_USER=""
  run git-auto-tagging.sh -repo_root=gitlab.digital.homeoffice.gov.uk/cdp_code/ -comp=auto-deploy-temp
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "GIT_USER must be set as an environment variable!!!" ]


  export GIT_USER="$SET_GIT_USER"
}

@test "invoking git-auto-tagging.sh without GIT_TOKEN set as an Environment variable prints error" {
skip
  SET_GIT_TOKEN="$GIT_TOKEN"
  export GIT_TOKEN=""
  run git-auto-tagging.sh -repo_root=gitlab.digital.homeoffice.gov.uk/cdp_code/ -comp=auto-deploy-temp
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "GIT_TOKEN must be set as an environment variable!!!" ]

  export GIT_TOKEN="$SET_GIT_TOKEN"
}


@test "invoking git-auto-tagging.sh without repo_root prints usage" {

  run git-auto-tagging.sh
  for i in {0..10}; do echo "${lines[i]}"; done
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Missing repo root!!!" ]
  [ "${lines[1]}" = "Usage: git-auto-tagging.sh -repo_root=github.com:UKHomeOffice/ -comp=auto-deploy-temp" ]
}


@test "invoking git-auto-tagging.sh without component name/ application name prints usage" {

  run git-auto-tagging.sh -repo_root=gitlab.digital.homeoffice.gov.uk/cdp_code/
  for i in {0..10}; do echo "${lines[i]}"; done
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = "Missing component!!!" ]
  [ "${lines[1]}" = "Usage: git-auto-tagging.sh -repo_root=github.com:UKHomeOffice/ -comp=auto-deploy-temp" ]
}

@test "invoking git-auto-tagging.sh with non-existent component prints error" {

  run git-auto-tagging.sh -repo_root=github.com:UKHomeOffice/ -comp=non-existent-comp
  for i in {0..20}; do echo "${lines[i]}"; done
  [ "$status" -ne 0 ]
  array_contains lines ">>>>>> Couldn't clone the repository!!!! \n"
}


@test "invoking git-auto-tagging.sh with correct arguments commits the next version and tag the component" {

    COMPONENT="auto-deploy-temp"

    #Given - current version is in .version file
    CURRENT_VERSION=v1.2.3
    EXPECTED_NEXT_VERSION=v1.2.4
    REPO="git@github.com:UKHomeOffice/$COMPONENT.git"
    git clone $REPO
    cd $COMPONENT

    #Write current version to .version file and push to git
    echo "$CURRENT_VERSION" > .version

    git commit -am "Updated version number to $CURRENT_VERSION"

    git push $REPO

    #Remove the cloned repo folder
    cd ..

    rm -Rf $COMPONENT


  #When
  run git-auto-tagging.sh -repo_root=github.com:UKHomeOffice/ -comp=$COMPONENT


  #Then

  [ "$status" == 0 ]

  array_contains lines ">>>>>> Cloned auto-deploy-temp  \n"

  cd $COMPONENT

  version=$(<.version)
  version=${version// /}

  #Check if version file contains the expected version
  [ "$version" == "$EXPECTED_NEXT_VERSION" ]

  #Check if tag created remotely
  git ls-remote --tags origin | grep "$EXPECTED_NEXT_VERSION"

  [ $? == 0 ]


  #Clean up

  #Delete local tag
  git tag --delete "$EXPECTED_NEXT_VERSION"

  [ $? == 0 ]

  #Delete remote tag
  git push --delete $REPO "$EXPECTED_NEXT_VERSION"

  [ $? == 0 ]

  cd ..
}

@test "invoking git-auto-tagging.sh when the current version is invalid then no tag is created" {

    COMPONENT="auto-deploy-temp"

    #Given - current version is in .version file
    CURRENT_VERSION=z1.2.3

    REPO="git@github.com:UKHomeOffice/$COMPONENT.git"
    git clone $REPO
    cd $COMPONENT

    #Write current version to .version file and push to git
    echo "$CURRENT_VERSION" > .version

    git commit -am "Updated version number to $CURRENT_VERSION"

    git push $REPO

    #Remove the cloned repo folder
    cd ..

    rm -Rf $COMPONENT

  #When
  run git-auto-tagging.sh -repo_root=github.com:UKHomeOffice/ -comp=$COMPONENT

    for i in {0..20}; do echo "${lines[i]}"; done
  #Then

  [ "$status" == 1 ]

  array_contains lines "Invalid version number, should conform to vMajor.Minor.Patch"

  cd $COMPONENT

  version=$(<.version)
  version=${version// /}

  #Check if version file still contains invalid CURRENT_VERSION
  [ "$version" == "$CURRENT_VERSION" ]

  #Check no tag created remotely
  tags=($(git ls-remote --tags origin))

 [ ${#tags[@]} -eq 0 ]

  cd ..
}


#!/usr/bin/env bash
<<COMMENT
    Self-tagging script which tags the current repo with the latest tag version's patch number increased by 1.

    The version is then bumped up using version-generator.sh.  The script then tags 
    the current repo with the new version.

    This script expects as input the environment GIT_DEPLOYMENT_KEY (a ssh-keygen private key)

    Assumptions: git ssh public key added to ssh-agent

    Usage: git-self-tag.sh 

COMMENT

function showUsage {
  echo "Usage: git-self-tagging.sh"
}

function checkIfExist {
    if [[ -z "$1" ]];
    then
        echo "$2"
        return 1
    fi
}


if [[  -z "${GIT_DEPLOYMENT_KEY}" ]]; then
  echo "failed to find GIT_DEPLOYMENT_KEY environment"
  exit 1
fi

git-set-creds-github.sh "$GIT_DEPLOYMENT_KEY"

# LPPM - this is not working w/ multiple tags pointing to the same commit
#version=$(git describe --tags $(git rev-list --tags --max-count=1 2>/dev/null) 2>/dev/null)
version=$(git tag |sort -V|tail -1 2>/dev/null)

if [[ -z "$version" ]]; then
  version="v0.0.0"
fi

nVersion=$(version-generator.sh "$version")
if [[ $? -ne 0 ]]; #Exit if version generator failed
then
  echo "invalid version $version"
  exit 2
fi

checkIfExist "$nVersion" ">>>>>> Next version can't be empty" || exit 2 

git tag "$nVersion" 
if [[ $? -ne 0 ]]; #Exit if version generator failed
then
  echo "failed to tag $nVersion locally"
  exit 3
fi



git push --tags 
if [[ $? -ne 0 ]]; #Exit if version generator failed
then
  echo "failed to push tag $nVersion; have you set your GIT_DEPLOYMENT_KEY environment var correctly? Does it match the public key in github?"
  exit 4
fi


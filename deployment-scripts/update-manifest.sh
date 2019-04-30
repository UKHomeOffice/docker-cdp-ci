#!/bin/bash

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

if [[ -z "$1" ]] || [[ -z "$2" ]]  || [[ -z "$3" ]]; then 
  echo "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>"
  exit -1;
fi

# we don't yet know where the manifest file is going to live (in git? in S3?) and how 
# it is going to be updated (flat structure if S3?)
# so stub this out for now
# NOTE 1: we might have to re-visit this script's signature, e.g. we might have to pass
# the CPD vesion as an extra parameter
# NOTE 2: the tests for this script have also been temporarily disabled
exit 0

# git_url=$1
# comp=$2
# uri=$3

# set -euo pipefail

# if [[ ! -z "${GIT_DEPLOYMENT_KEY+x}" ]]; then 
#   git-set-creds-github.sh "$GIT_DEPLOYMENT_KEY"
# fi

# cd $DIR
# repo_name=$(basename $git_url | sed -e 's/\.git$//')
# rm -rf $repo_name
# git clone --depth 1 --single-branch --branch master $git_url
# cd $DIR/$repo_name
# git pull
# git checkout -B "robot-${comp}"

# echo $uri > manifest/$comp

# git add manifest/$comp 
# git commit -m "New version of component $comp available on $uri"
# git push --set-upstream --force origin "robot-${comp}"
# git request-pull -p master ./

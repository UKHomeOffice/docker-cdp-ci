#!/usr/bin/env bash

if [[ -z "$0" ]] || [[ -z "$1" ]]  || [[ -z "$2" ]]; then 
  echo "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>"
  exit -1;
fi


git_url=$1
comp=$2
uri=$3

set -euo pipefail

if [[ ! -z "$GIT_DEPLOYMENT_KEY+x" ]]; then 
  git-set-credentials $GIT_DEPLOYMENT_KEY
fi

repo_name=$(echo $git_url| sed -e 's#.*/## ; s/.git//g')
git clone $git_url
if [[ $? -ne 0 ]]; then 
  echo "Failed to clone repo"
  exit -1
fi
git checkout -B "robot-${comp}"

echo $uri > $repo_name/manifest/$comp

git add $repo_name/manifest/$comp 
git commit -am"New version of component $comp available on $uri"
git push --set-upstream origin "robot-${comp}"
git request-pull -p master


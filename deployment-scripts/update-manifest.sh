#!/bin/bash -x

DIR="$( cd "$(dirname "$0")" ; pwd -P )"

if [[ -z "$1" ]] || [[ -z "$2" ]]  || [[ -z "$3" ]]; then 
  echo "Usage: update-manifest.sh <manifest-git-repo> <component-name> <image-uri>"
  exit -1;
fi


git_url=$1
comp=$2
uri=$3

set -euo pipefail

if [[ ! -z "${GIT_DEPLOYMENT_KEY+x}" ]]; then 
  git-set-creds-github.sh "$GIT_DEPLOYMENT_KEY"
fi

cd $DIR
repo_name=$(echo $git_url| sed -e 's#.*/## ; s/.git//g')
rm -rf $repo_name
git clone --depth 1 --single-branch --branch master $git_url
if [[ $? -ne 0 ]]; then 
  echo "Failed to clone repo"
  exit -1
fi
cd $DIR/$repo_name
git pull
git checkout -B "robot-${comp}"

echo $uri > manifest/$comp

git add manifest/$comp 
git commit -am "New version of component $comp available on $uri" || true
git push --set-upstream --force origin "robot-${comp}"
git request-pull -p master ./


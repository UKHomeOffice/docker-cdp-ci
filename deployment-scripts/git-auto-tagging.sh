#!/usr/bin/env bash
<<COMMENT
    Auto-tagging script which checks out a repo from gitlab/github and extracts the current version from .version file.

    The version is then bumped up using version-generator.sh and the new version is written back to .version file and checked into gitlab/github.

    The script then tags the repo with the new version.

    This script expects as input repository root path without the "https" and the name of the component/repo.

    Assumptions: GIT_USER and GIT_TOKEN set as environment variables

    Usage: git-auto-tagging.sh  -repo_root=github.com/UKHomeOffice/ -comp=auto-deploy-temp

COMMENT

# GITHUB_REPO_BASE_URL="github.com/UKHomeOffice/"
# GITLAB_REPO_BASE_URL="gitlab.digital.homeoffice.gov.uk/cdp_code/"
# COMPONENT_NAME="auto-deploy-temp"

# Needs to be set as an environment variable
# GIT_USER=

# Needs to be set as an environment variable
# GIT_TOKEN=

VERSION_FILE=".version"

function showUsage {
  echo "Usage: git-auto-tagging.sh -repo_root=github.com/UKHomeOffice/ -comp=auto-deploy-temp"
}

function gitTag {
    echo ">>>>>> tagging.. \n"
    git tag $nVersion

    git push $REPO $nVersion

    if [[ ! $? -eq 0 ]];
    then
    echo ">>>>>> Failed to push to remote!!!"
        exit 1
    fi
}

function checkIfExist {
    if [[ -z "$1" ]];
    then
        echo "$2"
        return 1
    fi
}

function checkIfExistOrShowUsage {
    checkIfExist "$1" "$2" || { showUsage; exit 1; }
}



for i in "$@"
do
case $i in
    -repo_root=*|--repo_root=*)
    REPO_BASE_URL="${i#*=}"
    ;;
    -comp=*|--component=*)
    COMPONENT_NAME="${i#*=}"
    ;;
esac
done

checkIfExist "$GIT_USER" "GIT_USER must be set as an environment variable!!!" || exit 1
checkIfExist "$GIT_TOKEN" "GIT_TOKEN must be set as an environment variable!!!" || exit 1
checkIfExistOrShowUsage "$REPO_BASE_URL" "Missing repo root!!!"
checkIfExistOrShowUsage "$COMPONENT_NAME" "Missing component!!!"

REPO="https://$GIT_USER:$GIT_TOKEN@$REPO_BASE_URL$COMPONENT_NAME.git"

echo ">>>>>> cloning >>> $REPO  \n"

git clone $REPO

if [[ ! $? -eq 0 ]];
then
    echo ">>>>>> Couldn't clone the repository!!!! \n"
    exit 1
fi

echo ">>>>>> Cloned $COMPONENT_NAME  \n"

#cd $COMPONENT_NAME

#Check if .version file exist

if [[ -e $COMPONENT_NAME/$VERSION_FILE ]];
 then
#    version=$(<.version)
    version=$(<$COMPONENT_NAME/$VERSION_FILE)
    version=${version// /}

    echo ">>>>>> current-version='$version'  \n"

    nVersion=$(version-generator.sh "$version")

    if [[ $? -gt 0 ]]; #Exit if version generator failed
    then
        echo "$nVersion"
        exit 1
    fi

    echo ">>>>>> nextVersion=$nVersion   \n"

    checkIfExist "$nVersion" ">>>>>> Next version can't be empty" || exit 1

    #Write next version to .version file
    echo "$nVersion" > $COMPONENT_NAME/$VERSION_FILE


    #checkin .version file
    echo ">>>>>> updating .version file with the next version \n"

    cd $COMPONENT_NAME
    git commit -am "Updated version number from $version to $nVersion"

    git push $REPO

    if [[ $? -eq 0 ]];
    then
        echo ">>>>>> updated .version file with the next version \n"

        #tag repo with the next version
        gitTag

        echo ">>>>>> tagged..  \n"
    else
        echo ">>>>>> Failed to push to remote!!!"
        exit 1
    fi
 else
    echo ">>>>>> $VERSION_FILE file doesn't exist in $COMPONENT_NAME \n"
    exit 1
fi

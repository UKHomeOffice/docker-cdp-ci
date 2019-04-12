#!/usr/bin/env bash

cVersion=$1

if [[ $# = 0 ]]; then
  echo "Usage: version-generator.sh [<current-version>]"
  echo "Please pass the current version number"
  exit 1
fi

#Check current version passed in matches pattern vMajor.Minor.Patch, eg., v1.2.3
regex='^(v)([0-9]+\.){0,2}(\*|[0-9]+)$'
 if [[ ! $cVersion =~ $regex ]];
  then
    echo "Invalid version number, should conform to vMajor.Minor.Patch"
    exit 1
 fi

echo "current-version=$cVersion"

OIFS=$IFS
IFS='.'
read majorV minorV patch <<< "$cVersion"
IFS=$OIFS

if [[ -z "$minorV" ]];
 then
    # If minor and patch number missing then set them to 0
      minorV=0
      patch=0
elif [[ -z "$patch" ]];
 then
  # If patch number missing then set it to 0
      patch=0
else
 # Increment the patch number
      patch=$((patch+1))
fi

nVersion="$majorV.$minorV.$patch"

echo "nextVersion=$nVersion"
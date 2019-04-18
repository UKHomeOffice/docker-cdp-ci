#!/usr/bin/env bash

<<COMMENT
    This script accepts as input current version number and increments the patch number.

    The current version passed must conform to this format - vMajor.Minor.Patch

    If Minor number is missing from the current version number it adds .0.0 to vMajor or if patch number is missing then it adds the .0

    For eg, if the current version is
                                v1, the nextVersion will be set as v1.0.0
                                v1.1,  the nextVersion will be set as v1.1.0
                                v1.1.2 the script will increment the patch number and the nextVersion will be set as v1.1.3
COMMENT


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


OIFS=$IFS
IFS='.'
read majorV minorV patch <<< "$cVersion"
IFS=$OIFS

if [[ -z "$minorV" ]];
 then
    # If minor and patch numbers are missing then set them to 0
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

echo "$nVersion"

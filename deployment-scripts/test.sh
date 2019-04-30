#!/bin/bash

function usage {
    cat << EOF
Usage: ${0} BASE_DIR ENV
Runs tests in the ENV environment.
BASE_DIR is the base folder containing the configurations for all environments

If environment variable TEST is defined, ${0} works in test/debug mode and prints out the output from kustomize
EOF
}

function error {
    colour='\033[0;31m'
    standard='\033[0m'
    echo -e "${colour}ERROR: ${@}${standard}" >&2
}


if [[ -z $1 ]] || [[ -z $2 ]]; then
    usage
    exit 1
fi

run-operation.sh test $1 $2
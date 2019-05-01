#!/bin/bash

function usage {
    cat << EOF
Usage: ${0} BASE_DIR ENV [PERF_TEST_JOB_GLOB PERF_TEST_CONF_GLOB PERF_TEST_TIMEOUT]
Runs tests in the ENV environment.
BASE_DIR is the base folder containing the configurations for all environments
PERF_TEST_JOB_GLOB is the wild card for k8s job definitions (defaults to *.yaml)
PERF_TEST_CONF_GLOB is the wild card for taurus test config files (defaults to *.yml)
PERF_TEST_TIMEOUT is the time in seconds to wait for the performance test to finish (defaults to 600)

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

# PERF_TEST_JOB_GLOB is the wild card for k8s job definitions
export PERF_TEST_JOB_GLOB=${3:-*.yaml}
# PERF_TEST_CONF_GLOB is the wild card for taurus test config files
export PERF_TEST_CONF_GLOB=${4:-*.yml}
# PERF_TEST_TIMEOUT is the time in seconds to wait for the performance test to finish
export PERF_TEST_TIMEOUT=${5:-600}

run-operation.sh test $1 $2
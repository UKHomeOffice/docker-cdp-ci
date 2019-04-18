#!/usr/bin/env bash

if [[ -z $1 ]]; then
    cat << EOF
Usage: ${0} SERVER
Adds SERVER to the ssh known hosts file
EOF
    exit 1
fi

# bail out if we encounter any errors
set -euo pipefail

SERVER=$1

mkdir -p ${HOME}/.ssh
touch ${HOME}/.ssh/known_hosts
chmod 600 ${HOME}/.ssh/known_hosts
ssh-keyscan -H $SERVER >> ${HOME}/.ssh/known_hosts 2> /dev/null

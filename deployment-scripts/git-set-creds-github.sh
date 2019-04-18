#!/usr/bin/env bash

if [[ -z $1 ]]; then
    echo "expected a parameter: (private) ssh_key"
    exit 1
fi

# bail out if we encounter any errors
set -euo pipefail

SSH_KEY=$1

mkdir -p ${HOME}/.ssh
echo -n "$SSH_KEY" > ${HOME}/.ssh/id_rsa
chmod 600 ${HOME}/.ssh/id_rsa

set-known-hosts.sh github.com

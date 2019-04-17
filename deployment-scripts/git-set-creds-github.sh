#!/usr/bin/env bash

if [[ -z $1 ]]; then
    echo "expected a parameter: (private) ssh_key"
    exit 1
fi

SSH_KEY=$1

mkdir -p ${HOME}/.ssh
echo -n "$SSH_KEY" > ${HOME}/.ssh/id_rsa
chmod 600 ${HOME}/.ssh/id_rsa

touch ${HOME}/.ssh/known_hosts
chmod 600 ${HOME}/.ssh/known_hosts
ssh-keyscan -H github.com >> ${HOME}/.ssh/known_hosts 2> /dev/null
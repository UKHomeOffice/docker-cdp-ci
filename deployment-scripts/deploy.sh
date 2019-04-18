#! /bin/bash

function usage {
    cat << EOF
Usage: ${0} BASE_DIR ENV GIT_HUB_DEPLOYMENT_KEY
Deploys to the ENV environment.
BASE_DIR is the base folder containing the configurations for all environments
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

export BASE_DIR=$1
export KUBE_NAMESPACE=$2

set -euo pipefail
# automatically export all environment variables

export ENV_BASE_DIR="${BASE_DIR}/environments/${KUBE_NAMESPACE}"

if [[ ! -d "${BASE_DIR}" ]] ; then
    error "Invalid BASE_DIR"
    usage
    exit 2
fi

if [[ ! -d "${ENV_BASE_DIR}" ]] ; then
    error "Environment ${KUBE_NAMESPACE} not found"
    if [[ -d "${BASE_DIR}/environments" ]]; then
        echo "Valid environments:"
        ls "${BASE_DIR}/environments"
        exit 3
    else
        error "Expected environments folder under ${BASE_DIR}. Is BASE_DIR valid (have you mounted the volume)?"
        usage
        exit 4
    fi
fi

if [ -z "${DRONE_BUILD_NUMBER+x}" ]; then
    # You will need to create the following file from the template
    if [[ ! -f "${BASE_DIR}/deploy.cfg" ]];then
      error "Cound not find ${BASE_DIR}/deploy.cfg; You will need to create it following file from the deploy.template.cfg file"
      exit 5
    fi
    source "${BASE_DIR}/deploy.cfg"
fi

DEBUG="${DEBUG:-}"

export BUILD_NUMBER=${DRONE_BUILD_NUMBER:-`date "+%Y%m%dt%H%M%S"`}

TAG=$(cat ${ENV_BASE_DIR}/cdp-version)

CDP_DEPLOYMENT_TEMPLATES_DIR=${ENV_BASE_DIR}/cdp-deployment-templates
rm -rf ${CDP_DEPLOYMENT_TEMPLATES_DIR}
cd ${ENV_BASE_DIR}
git clone --branch ${TAG} --depth 1 https://github.com/UKHomeOffice/cdp-deployment-templates.git
cd -

set -a
source "${CDP_DEPLOYMENT_TEMPLATES_DIR}/vars/common.cfg"
source "${ENV_BASE_DIR}/conf.cfg"
set +a

kubectl="kubectl --insecure-skip-tls-verify --server=${KUBE_SERVER} --namespace=${KUBE_NAMESPACE} --token=${KUBE_TOKEN}"

echo "Beginning deployment to ${KUBE_NAMESPACE}."

kustomize build ${ENV_BASE_DIR}| envsubst | ${kubectl} apply -f - 

echo "All resources updated."

for d in `${kubectl} get deploy -o name`; do
    ${kubectl} rollout status "${d}"
done

echo "Complete."

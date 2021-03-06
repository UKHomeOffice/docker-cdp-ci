#!/bin/bash

function usage {
    cat << EOF
Usage: ${0} OPERATION BASE_DIR ENV
Runs OPERATION in the ENV environment.
OPERATION can be:
  * 'deploy': deploys the application
  * 'test': runs performance tests
BASE_DIR is the base folder containing the configurations for all environments

If environment variable TEST is defined, ${0} works in test/debug mode and prints out the output from kustomize
EOF
}

function error {
    colour='\033[0;31m'
    standard='\033[0m'
    echo -e "${colour}ERROR: ${@}${standard}" >&2
}


if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
    usage
    exit 1
fi

export OPERATION=$1
export BASE_DIR=$2
export KUBE_NAMESPACE=$3

set -euo pipefail

export ENV_BASE_DIR="${BASE_DIR}/environments/${KUBE_NAMESPACE}"
export ENV_OPERATION_BASE_DIR="${ENV_BASE_DIR}/${OPERATION}"

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
        error "Expected test folder under ${BASE_DIR}/environments/${KUBE_NAMESPACE}. Is BASE_DIR valid (have you mounted the volume)?"
        usage
        exit 4
    fi
fi

if [[ ! -d "${ENV_OPERATION_BASE_DIR}" ]] ; then
    error "Directory ${ENV_OPERATION_BASE_DIR} not found"
    exit 5
fi

if [ -z "${DRONE_BUILD_NUMBER+x}" ]; then
    # You will need to create the following file from the template
    if [[ ! -f "${BASE_DIR}/deploy.cfg" ]];then
      error "Cound not find ${BASE_DIR}/deploy.cfg; You will need to create it following file from the deploy.template.cfg file"
      exit 6
    fi
    source "${BASE_DIR}/deploy.cfg"
fi

DEBUG="${DEBUG:-}"

export BUILD_NUMBER=${DRONE_BUILD_NUMBER:-`date "+%Y%m%dt%H%M%S"`}

TAG=$(cat ${ENV_BASE_DIR}/cdp-version)

CDP_DEPLOYMENT_TEMPLATES_DIR=${ENV_OPERATION_BASE_DIR}/cdp-deployment-templates
rm -rf ${CDP_DEPLOYMENT_TEMPLATES_DIR}
cd ${ENV_OPERATION_BASE_DIR}
git clone -q --branch ${TAG} --depth 1 https://github.com/UKHomeOffice/cdp-deployment-templates.git 2> /dev/null
cd -

# automatically export all environment variables
set -a
source "${CDP_DEPLOYMENT_TEMPLATES_DIR}/vars/common.cfg"
source "${ENV_BASE_DIR}/conf.cfg"
set +a

if [[ -z ${KUBE_CERTIFICATE_AUTHORITY_DATA+x} ]]; then
    kubectl="kubectl --insecure-skip-tls-verify --server=${KUBE_SERVER} --namespace=${KUBE_NAMESPACE} --token=${KUBE_TOKEN}"
else
    echo ${KUBE_CERTIFICATE_AUTHORITY_DATA} | base64 -d > /tmp/kube-ca
    kubectl="kubectl --certificate-authority=/tmp/kube-ca --server=${KUBE_SERVER} --namespace=${KUBE_NAMESPACE} --token=${KUBE_TOKEN}"
fi

# if env var TEST is defined, we are testing this script
if [[ -z "${TEST+x}" ]]; then 
  # deployment pre-processing
  if [[ $OPERATION == "test" ]]; then
    # Get an access token from Keycloak
    export ACCESS_TOKEN=$(curl -sSf -d "client_id=${KEYCLOAK_CLIENT_ID}&client_secret=${KEYCLOAK_CLIENT_SECRET}&grant_type=client_credentials" \
                            https://${KEYCLOAK_URL}/auth/realms/${KEYCLOAK_REALM}/protocol/openid-connect/token | \
                            jq -r .access_token)
    # and store it as Kubernetes secret for the Taurus job to pick up                          
    ${kubectl} delete secret access-token || true
    ${kubectl} create secret generic access-token --from-literal=access_token=$ACCESS_TOKEN
  fi

  # TEST is undefined so run a proper deployment or performance test
  echo "Beginning deployment to ${KUBE_NAMESPACE}."

  kustomize build ${ENV_OPERATION_BASE_DIR} | envsubst | ${kubectl} apply -f - 
  
  # deployment post-processing
  if [[ $OPERATION == "deploy" ]]; then
    echo "All resources updated."

     ${kubectl} wait --for=condition=Available "--timeout=${DEPLOYMENT_TIMEOUT:-300}s" --all deployments

    echo "Complete."
  elif [[ $OPERATION == "test" ]]; then
    for test_rc in "${ENV_OPERATION_BASE_DIR}/cdp-deployment-templates/k8s-perf-test/${PERF_TEST_JOB_GLOB}" ; do
      export PERF_TEST_NAME="${PERF_TEST_NAME:-$(echo ${DRONE_REPO} | sed -e 's#.*/##g')-$(date +%s%3N)-${RANDOM}}"
      cat ${test_rc} | envsubst | ${kubectl} create -f -

      # disable catching errors
      set +e
      #${kubectl} wait --for=condition=complete "--timeout=${PERF_TEST_TIMEOUT}s" "job/${PERF_TEST_NAME}"
      until [[ $SECONDS -gt $PERF_TEST_TIMEOUT ]] || 
            [[ $(${kubectl} get jobs $PERF_TEST_NAME -o jsonpath='{.status.conditions[?(@.type=="Failed")].status}') == "True" ]] || 
            [[ $(${kubectl} get jobs $PERF_TEST_NAME -o jsonpath='{.status.conditions[?(@.type=="Complete")].status}') == "True" ]]; do
              SECONDS=$(( SECONDS + 1))
              sleep 1;
      done

      # re-enable catching errors
      set -e

      # work out the pod names that ran the job
      PERF_POD_NAMES=$(${kubectl} get pod "--selector=job-name=${PERF_TEST_NAME}" --output=jsonpath={.items..metadata.name})
      ${kubectl} get pod "--selector=job-name=${PERF_TEST_NAME}" --output=json

      STATUS=$( ${kubectl} get pod "--selector=job-name=${PERF_TEST_NAME}" -o jsonpath='{.items..status.containerStatuses..state.terminated.exitCode}')
      echo "POD NAME = ${PERF_POD_NAMES}; status = $STATUS"

      # output the job's logs
      ${kubectl} logs ${PERF_POD_NAMES}

      ${kubectl} delete job "${PERF_TEST_NAME}"

      ${kubectl} delete secret access-token || true

      if [[ ${STATUS} != 0 ]]; then
        echo "job did not complete in a healthy status: ${STATUS}"
        exit ${STATUS}
      fi
    done

    echo "All resources updated."

    exit 0

    # for d in `${kubectl} get deploy -o name`; do
    #     ${kubectl} rollout status "${d}"
    # done
    # echo "Complete."
  fi

else
  # TEST is defined
  # we are testing this script
  # so output the resource definitions that would normally be processed by kubectl
  kustomize build ${ENV_OPERATION_BASE_DIR} 

  if [[ $OPERATION == "test" ]]; then
    for test_rc in "${ENV_OPERATION_BASE_DIR}/cdp-deployment-templates/k8s-perf-test/${PERF_TEST_JOB_GLOB}" ; do
      export PERF_TEST_NAME="${PERF_TEST_NAME:-$(echo ${DRONE_REPO} | sed -e 's#.*/##g')-$(date +%s%3N)-${RANDOM}}"
      cat ${test_rc}
    done
  fi
fi


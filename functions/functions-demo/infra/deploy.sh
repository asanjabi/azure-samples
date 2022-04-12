#! /bin/bash
set -euxo pipefail

#switch to the current scripts directory
DEPLOY_SCIRIPT_DIR="${0%/*}"
export DEPLOY_SCIRIPT_DIR
pushd "$DEPLOY_SCIRIPT_DIR"

#Define relative root and load some utilities
export ROOT=../
source "${DEPLOY_SCIRIPT_DIR}"/utils.sh

loadEnvironment

#Check for required environment variables
unset error
checkEnvDefined ResourceGroup
checkEnvDefined Location

exitIfDefined error

#Make sure we are logged into Azure
source "${DEPLOY_SCIRIPT_DIR}"/login.sh

#This is here because the template file has $schema in it that is not part of the template.
schema="schema"
export schema

eval "cat <<EOF
$(cat "${DEPLOY_SCIRIPT_DIR}/parameters.template.json")
EOF" > "${DEPLOY_SCIRIPT_DIR}"/parameters.json.secret

createRg "${ResourceGroup:?}" "${Location:?}"

az deployment group create \
    -g "${ResourceGroup:?}" \
    -n "${ResourceGroup:?}"-deployment \
    -f main.bicep \
    -p @parameters.json.secret


rm "${DEPLOY_SCIRIPT_DIR}"/parameters.json.secret
popd
set +euxo pipefail
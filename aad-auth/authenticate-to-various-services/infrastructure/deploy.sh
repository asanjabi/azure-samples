#! /bin/bash
set -euxo pipefail

#switch to the current scripts directory
DEPLOY_SCIRIPT_DIR="${0%/*}"
export DEPLOY_SCIRIPT_DIR
pushd "$DEPLOY_SCIRIPT_DIR"

#Define relative root and load some utilities
export "ROOT="../../..
source "${ROOT}"/infra/scripts/utils.sh

loadEnvironment

#Check for required environment variables
unset error
checkEnvDefined ResourceGroup
checkEnvDefined Location

exitIfDefined error

#Make sure we are logged into Azure
source "${ROOT}"/infra/scripts/login.sh

#Figure out the admin
source "${ROOT}"/infra/scripts/ad.sh

#sort out admin
getBestSid ${AdminName:-} AdminSid AdminSidType AdminLogin

createRg "${ResourceGroup:?}" "${Location:?}"

az deployment group create -g "${ResourceGroup:?}" -n "${ResourceGroup:?}"-deployment \
    -f main.bicep \
    -p AdminSid=$AdminSid \
    -p AdminSidType=$AdminSidType \
    -p AdminLogin=$AdminLogin

popd
set +euxo pipefail
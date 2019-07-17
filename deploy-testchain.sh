#!/usr/bin/env bash

# shellcheck source=lib/common.sh
. "${LIB_DIR:-$(cd "${0%/*}/lib"&&pwd)}/common.sh"
writeConfigFor "testchain"

export CASE="$LIBEXEC_DIR/cases/$1"

[[ $# -gt 0 && ! -f "$CASE" ]] && exit 1

# Send ETH to Omnia Relayer
OMNIA_RELAYER=$(jq -r ".omniaFromAddr" "$CONFIG_FILE")
seth send "$OMNIA_RELAYER" --value "$(seth --to-wei 10000 eth)"

export DEPLOY_RESTRICTED_FAUCET="no"
"$LIBEXEC_DIR"/base-deploy

if [[ -f "$CASE" ]]; then
    log "TESTCHAIN DEPLOYMENT + ${1} COMPLETED SUCCESSFULLY"
else
    log "TESTCHAIN DEPLOYMENT COMPLETED SUCCESSFULLY"
fi

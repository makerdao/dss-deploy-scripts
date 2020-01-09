#!/usr/bin/env bash

# shellcheck source=lib/check-params.sh
. "$LIB_DIR/check-params.sh"

# shellcheck source=lib/common.sh
. "$LIB_DIR/common.sh"

writeConfigFor "testchain"

# Send ETH to Omnia Relayer
sethSend "$(jq -r ".omniaFromAddr" "$CONFIG_FILE")" --value "$(seth --to-wei "$(jq -r ".omniaAmount" "$CONFIG_FILE")" eth)"

export DEPLOY_RESTRICTED_FAUCET="no"
"$LIBEXEC_DIR"/base-deploy |& tee "$OUT_DIR/dss_testchain.log"

if [[ -f "$CASE" ]]; then
    log "TESTCHAIN DEPLOYMENT + ${1} COMPLETED SUCCESSFULLY"
else
    log "TESTCHAIN DEPLOYMENT COMPLETED SUCCESSFULLY"
fi

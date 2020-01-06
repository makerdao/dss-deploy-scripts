#!/usr/bin/env bash

if [[ "$IN_NIX_SHELL" != "yes" ]]; then
    echo "This command must be run via nix-shell"
    exit 1
fi
if [[ -z "$BIN_DIR" ]]; then
    echo "This command must be called without \"./\""
    exit 1
fi

# shellcheck source=lib/common.sh
. "$LIB_DIR/common.sh"
writeConfigFor "testchain"

export CASE="$LIBEXEC_DIR/cases/$1"

[[ $# -gt 0 && ! -f "$CASE" ]] && exit 1

# Send ETH to Omnia Relayer
sethSend "$(jq -r ".omniaFromAddr" "$CONFIG_FILE")" --value "$(seth --to-wei "$(jq -r ".omniaAmount" "$CONFIG_FILE")" eth)"

export DEPLOY_RESTRICTED_FAUCET="no"
"$LIBEXEC_DIR"/base-deploy |& tee "$OUT_DIR/dss_testchain.log"

if [[ -f "$CASE" ]]; then
    log "TESTCHAIN DEPLOYMENT + ${1} COMPLETED SUCCESSFULLY"
else
    log "TESTCHAIN DEPLOYMENT COMPLETED SUCCESSFULLY"
fi

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
writeConfigFor "kovan"

test "$(seth chain)" == "kovan" || exit 1

export DEPLOY_RESTRICTED_FAUCET="no"
"$LIBEXEC_DIR"/base-deploy |& tee "$OUT_DIR/dss_kovan.log"

log "KOVAN DEPLOYMENT COMPLETED SUCCESSFULLY"

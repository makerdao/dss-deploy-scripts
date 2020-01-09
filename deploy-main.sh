#!/usr/bin/env bash

# shellcheck source=lib/check-params.sh
. "$LIB_DIR/check-params.sh"

# shellcheck source=lib/common.sh
. "$LIB_DIR/common.sh"

writeConfigFor "main"

test "$(seth chain)" == "ethlive" || exit 1

export DEPLOY_RESTRICTED_FAUCET="yes"
"$LIBEXEC_DIR"/base-deploy |& tee "$OUT_DIR/dss_mainnet.log"

log "MAINNET DEPLOYMENT COMPLETED SUCCESSFULLY"
